require_relative '../api'

class DiabetesLogsAPIRoutes < APIRoutes
  #/api/logs
  route do |r|
    r.on /(\d+)/ do |log_id|
      @log = DiabetesLog[log_id.to_i] || not_found!
      r.get do
        r.is do
          read! @log
        end
      end

      r.put do
        current_user || unauthorized!
        current_user.id == @log.cat.user_id || forbidden!
        r.is do
          update! DiabetesLog, @log.id, params
        end
      end

      r.delete do
        current_user || unauthorized!
        current_user.id == @log.cat.user_id || forbidden!
        r.is do
          destroy! DiabetesLog, @log.id
        end
      end
    end

    r.get do
      r.is do
        halt 200, body: { diabetes_logs: DiabetesLog.all }
      end
    end

    r.post do
      current_user || unauthorized!
      r.is do
        create! DiabetesLog, params
      end
    end
  end
end
