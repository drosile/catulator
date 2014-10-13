class CatulatorAPIClient
  module Cats
    def create_cat(attrs)
      post('cats', headers: auth_header, parameters: attrs)
    end

    def get_cat(id)
      get("cats/#{id}", headers: auth_header)
    end

    def edit_cat(id, attrs)
      put("cats/#{id}", headers: auth_header, parameters: attrs)
    end

    def delete_cat(id)
      delete("cats/#{id}", headers: auth_header)
    end
  end
end
