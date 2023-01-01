# frozen_string_literal: true

missing = Devpack::Gems.new(Devpack.config).tap { |gems| gems.load(silent: true) }.missing
install_command = "bundle exec gem install -V #{missing.map(&:required_version).join(' ')}" unless missing.empty?
if install_command.nil?
  Devpack.warn(:info, Devpack::Messages.no_gems_to_install)
else
  Devpack.warn(:info, install_command)
  output, status = Open3.capture2e(install_command)
  if status.success?
    Devpack.warn(:success, 'Installation complete.')
  else
    Devpack.warn(:error, "Installation failed. Manually verify this command: #{install_command}")
    puts output
  end
end
exit 0
