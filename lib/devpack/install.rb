# frozen_string_literal: true

missing = Devpack::Gems.new(Devpack.config).tap { |gems| gems.load(silent: true) }.missing
install_command = "bundle exec gem install -V #{missing.map(&:required_version).join(' ')}" unless missing.empty?
if install_command.nil?
  warn '[devpack] No gems to install.'
else
  warn "[devpack] [exec] #{install_command}"
  output, status = Open3.capture2e(install_command)
  puts output
  puts status
  if status.success?
    warn '[devpack] Installation complete.'
  else
    warn "[devpack] Installation failed. Manually verify this command: #{install_command}"
  end
end
exit 0
