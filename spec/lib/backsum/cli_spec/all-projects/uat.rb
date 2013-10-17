name "uat"

EXCLUDED_FILES = ["logs", "assets"]
server "uat.bstar.wido.me", username: "www-data" do
  folder "/var/www/demo/apps/balm/shared", excluded: EXCLUDED_FILES, as: "balm"
  folder "/var/www/demo/apps/balm-game/shared", excluded: EXCLUDED_FILES
end