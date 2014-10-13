class CatulatorAPIClient
  module Logs
    def create_log(attrs)
      post('logs', headers: auth_header, parameters: attrs)
    end

    def get_logs
      get("logs", headers: auth_header)
    end

    def get_log(id)
      get("logs/#{id}", headers: auth_header)
    end

    def edit_log(id, attrs)
      put("logs/#{id}", headers: auth_header, parameters: attrs)
    end

    def delete_log(id)
      delete("logs/#{id}", headers: auth_header)
    end
  end
end
