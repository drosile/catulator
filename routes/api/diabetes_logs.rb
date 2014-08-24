require_relative '../api'

class DiabetesLogsAPIRoutes < APIRoutes
  #/api/logs
  route do |r|
    r.on /(\d+)/ do |log_id|
      @log = DiabetesLog[log_id.to_i] || not_found!

      r.get true do
        read! @log
      end

      r.put true do
        current_user || unauthorized!
        current_user.id == @log.cat.user_id || admin? || forbidden!

        update! DiabetesLog, @log.id, params
      end

      r.delete true do
        current_user || unauthorized!
        current_user.id == @log.cat.user_id || admin? || forbidden!

        destroy! DiabetesLog, @log.id
      end
    end

    r.get true do
      halt 200, body: { diabetes_logs: DiabetesLog.all }
    end

    r.post true do
      current_user || unauthorized!
      cat = Cat[params[:cat_id]] || error!([cat_id: 'invalid_id'])
      current_user.id == cat.user_id || admin? || forbidden!

      create! DiabetesLog, params
    end
  end
end
