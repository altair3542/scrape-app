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

    def def scrape_websites_and_phone_numbers

      @businesses = Business.all
      agent = Mechanize.new

      @businesses.each do |business|
        begin
          page = agent.get(business.sitio_web)

          # Extraer el número de teléfono usando una regex
          telefono_match = page.body.match(/(\+34\s?)?(\d{9})/)
          telefono = telefono_match[2] if telefono_match

          # Eliminar el código de país si está presente
          telefono.sub!(/\+34\s?/, '') if telefono

          # Actualizar el campo de teléfono en la base de datos
          business.update(telefono: telefono) if telefono
        rescue StandardError => e
          puts "Error al procesar #{business.sitio_web}: #{e.message}"
        end
      end

      redirect_to businesses_path, notice: 'Scraping completado exitosamente.'
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



end
