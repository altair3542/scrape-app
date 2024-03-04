require 'mechanize'
class BusinessesController < ApplicationController
  # app/controllers/empresas_controller.rb
  def index
    @businesses = Business.all
  end

  def new_excel_upload
  end

  def create_excel_upload
    file = params[:file]

    if file.present? && file.original_filename.ends_with?('.xls', '.xlsx')
      spreadsheet = Roo::Excelx.new(file.path)

      spreadsheet.each_row_streaming(offset: 1) do |row|
        # Asigna los valores a las columnas según tu archivo Excel
        nombre = row[0]&.value
        correo_electronico = row[1]&.value
        ciudad = row[2]&.value
        servicios = row[3]&.value

        business_params = {
          nombre: nombre,
          correo_electronico: correo_electronico,
          ciudad: ciudad,
          servicios: servicios
        }

        # Clona el campo correo_electronico en sitio_web
        business_params[:sitio_web] = correo_electronico.split('@').last if correo_electronico.present?

        Business.create(business_params)
      end

      redirect_to businesses_path, notice: 'Carga desde Excel exitosa.'
    else
      redirect_to new_excel_upload_businesses_path, alert: 'Por favor, seleccione un archivo Excel válido.'
    end
  end


  def export_to_excel
    @businesses = Business.all

    workbook = export_excel
    file_path = 'tmp/empresas.xlsx' # Guardamos el archivo en el sistema de archivos temporal

    workbook.close

    send_file file_path, filename: 'empresas.xlsx', type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
  end




  def scrape_and_save
      base_url = 'https://elkit.cat/?cn-reloaded=1'
      total_pages = 2  # Puedes ajustar esto al número total de páginas que deseas raspar

      (1..total_pages).each do |page_number|
        begin
          puts "Raspando la página #{page_number}..."
          page = scrape_page(base_url)
          data = extract_data_from_page(page)

          # Almacena los datos en la base de datos
          save_data_to_database(data)
        rescue StandardError => e
          puts "Error al raspar la página #{page_number}: #{e.message}"
          break  # Sal del bucle en caso de error
        end
      end

      puts "Raspado completado. Los resultados se han guardado en la base de datos."
      redirect_to businesses_path
    end


    def scrape_websites_and_phone_numbers
      @businesses = Business.all

      @businesses.each do |business|
        begin
          puts "Raspando la página de #{business.nombre}..."

          # Verifica si el enlace es una URL absoluta
          url = business.sitio_web.start_with?('http') ? business.sitio_web : "http://#{business.sitio_web}"

          page = scrape_page(url)
          phone_number = extract_phone_number_from_page(page)

          # Actualiza el número de teléfono en la base de datos
          business.update(telefono: phone_number) if phone_number.present?
        rescue StandardError => e
          puts "Error al raspar la página de #{business.nombre}: #{e.message}"
        end
      end

      puts "Raspado de teléfonos completado. Los resultados se han actualizado en la base de datos."
      redirect_to businesses_path
    end


    private

    def wait_for_element(driver, selector)
      # La implementación de wait_for_element permanece igual
    end

    def scrape_page(base_url)
      # La implementación de scrape_page permanece igual, pero ajusta el retorno del Nokogiri::HTML
      Nokogiri::HTML(driver.page_source)
    end

    def extract_data_from_page(page)
      # La implementación de extract_data_from_page permanece igual
    end

    def save_data_to_database(data)
      # Almacena los datos en la base de datos
      data.each do |row|
        Empresa.create(
          nombre: row[0],
          correo_electronico: row[1],
          ciudad: row[2],
          servicios: row[3]
        )
      end
    end

    def scrape_page(url)
      agent = Mechanize.new
      page = agent.get(url)
      Nokogiri::HTML(page.body)
    end

    def extract_phone_number_from_page(page)
      # Selecciona tanto el footer como el header utilizando selectores adecuados
      footer = page.css('footer')
      header = page.css('header')

      # Combina el contenido del footer y del header
      combined_content = footer.to_s + header.to_s

      # Expresión regular para encontrar secuencias de números de 9 dígitos
      phone_number_regex = /\b[6-9]\d{8}\b/

      # Busca la expresión regular en el contenido combinado
      match = combined_content.scan(phone_number_regex).flatten.compact

      # Filtra los números que comienzan con 6, 7, 8 o 9
      filtered_numbers = match.select { |number| ['6', '7', '8', '9'].include?(number[0]) }

      # Retorna el primer número de teléfono encontrado después del filtrado
      phone_number = filtered_numbers[0] if filtered_numbers.present?

      phone_number
    end




  end
