name "yst"

EXCLUDED_FILES = ["logs", "assets"]
server "ocn-pro-yst", username: "www-data" do
  folder "/var/www/starcloud/apps/portal/shared", excluded: EXCLUDED_FILES, as: "yst-portal"
end