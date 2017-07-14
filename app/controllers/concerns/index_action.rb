module IndexAction
  ## routed actions
  def list
    table = create_datatable.extend(Datatable::Serverside).set_params(params)
    render json: table
  end
  def index
    table = create_datatable

    respond_to do |format|
      format.html {
        additional_settings = {
          serverSide: true,
          ajax: {
            url: url_for(action: :list, format: :json, params: params.permit!),
          },
        }
        render :index, locals: {
          table: table.add_settings(additional_settings)
        }
      }
      format.json { render json: table   }
      format.csv { send_data table.to_csv, filename: "#{controller_name}.csv" }
    end
  end

  ################
  # unrouted methods
  def create_datatable
    klass = "#{controller_name.camelize}Datatable".constantize
    klass.new do |obj|
      yield obj if block_given?
    end
  end
end
