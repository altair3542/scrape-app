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

        Business.create(
          nombre: nombre,
          correo_electronico: correo_electronico,
          ciudad: ciudad,
          servicios: servicios
        )
      end

      redirect_to businesses_path, notice: 'Carga desde Excel exitosa.'
    else
      redirect_to new_excel_upload_businesses_path, alert: 'Por favor, seleccione un archivo Excel válido.'
    end
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
