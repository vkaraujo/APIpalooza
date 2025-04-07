module PagesHelper
  def api_lineup
    @api_lineup ||= YAML.load_file(Rails.root.join("config/api_lineup.yml"))
  end
end
