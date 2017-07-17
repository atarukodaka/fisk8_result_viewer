module IndexActions
  ## routed actions
  def list
    render json: create_datatable(serverside: true)
  end
  def index
    table = create_datatable

    respond_to do |format|
      format.html {
        serverside_settings = {
          serverSide: true,
          ajax: {
            url: url_for(action: :list, format: :json, params: params.permit!),
          },
        }
        render :index, locals: {
          table: table.update_settings(serverside_settings)
        }
      }
      format.json { render json: table   }
      format.csv { send_data table.to_csv, filename: "#{controller_name}.csv" }
    end
  end

  ################
  # unrouted methods
  def create_datatable(serverside: false)
    klass = "#{controller_name.camelize}Datatable".constantize
    table = klass.new do |obj|
      yield obj if block_given?
    end.params(params)
    #(serverside) ? table.extend(Datatable::Serverside).set_params(params) : table
    (serverside) ? table.extend(Datatable::Serverside) : table
  end
end
