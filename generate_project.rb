require 'xcodeproj'

PROJECT_NAME = 'BlindLoup'
BUNDLE_ID    = 'com.blindloup.app'
TEAM_ID      = ''  # Set your Apple Developer Team ID here
IOS_TARGET   = '17.0'

# All source files with their group paths
SOURCE_FILES = {
  'BlindLoup/App'                          => %w[BlindLoupApp.swift RootView.swift],
  'BlindLoup/Models'                       => %w[Player.swift Track.swift GameRound.swift GamePhase.swift],
  'BlindLoup/ViewModels'                   => %w[GameViewModel.swift SearchViewModel.swift],
  'BlindLoup/Services'                     => %w[DeezerService.swift AudioPlayerService.swift StoreKitService.swift GameHistoryService.swift],
  'BlindLoup/Utilities'                    => %w[AppColors.swift AppConstants.swift Extensions.swift],
  'BlindLoup/Views/Home'                   => %w[HomeView.swift PremiumPaywallView.swift HowToPlayView.swift GameHistoryView.swift GameModeCard.swift],
  'BlindLoup/Views/Setup'                  => %w[PlayerSetupView.swift],
  'BlindLoup/Views/Selection'              => %w[SecretSelectionView.swift TrackSearchView.swift TransitionView.swift],
  'BlindLoup/Views/Game'                   => %w[BlindTestView.swift AudioPlayerView.swift],
  'BlindLoup/Views/Voting'                 => %w[VotingView.swift],
  'BlindLoup/Views/Results'                => %w[RevealView.swift FinalScoreView.swift],
  'BlindLoup/Views/Components'             => %w[PrimaryButton.swift TrackRowView.swift PlayerScoreRow.swift ProtectionScreen.swift],
}

project_path = "#{PROJECT_NAME}.xcodeproj"
project = Xcodeproj::Project.new(project_path)

# Create main target
target = project.new_target(:application, PROJECT_NAME, :ios, IOS_TARGET)

# Create Sources build phase if not already present
sources_phase = target.source_build_phase

# Create info.plist
info_plist_path = "#{PROJECT_NAME}/Info.plist"

# Helper: get or create group by path
def get_or_create_group(project, group_path)
  parts = group_path.split('/')
  group = project.main_group
  parts.each do |part|
    existing = group.children.find { |c| c.is_a?(Xcodeproj::Project::Object::PBXGroup) && c.name == part }
    if existing
      group = existing
    else
      new_group = group.new_group(part)
      new_group.source_tree = '<group>'
      group = new_group
    end
  end
  group
end

# Add all source files
SOURCE_FILES.each do |group_path, files|
  group = get_or_create_group(project, group_path)
  files.each do |filename|
    file_path = "#{group_path}/#{filename}"
    file_ref = group.new_file(file_path)
    file_ref.source_tree = '<group>'
    file_ref.last_known_file_type = 'sourcecode.swift'
    target.source_build_phase.add_file_reference(file_ref)
  end
end

# Add Info.plist reference
info_group = get_or_create_group(project, PROJECT_NAME)
info_ref = info_group.new_file("Info.plist")
info_ref.source_tree = '<group>'
info_ref.last_known_file_type = 'text.plist.xml'

# Add StoreKit configuration
sk_group = get_or_create_group(project, PROJECT_NAME)
sk_ref = sk_group.new_file("Products.storekit")
sk_ref.source_tree = '<group>'

# Build configurations
debug_config   = target.build_configurations.find { |c| c.name == 'Debug' }
release_config = target.build_configurations.find { |c| c.name == 'Release' }

[debug_config, release_config].each do |config|
  next unless config
  config.build_settings['PRODUCT_BUNDLE_IDENTIFIER']      = BUNDLE_ID
  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']     = IOS_TARGET
  config.build_settings['SWIFT_VERSION']                  = '5.9'
  config.build_settings['TARGETED_DEVICE_FAMILY']         = '1'
  config.build_settings['INFOPLIST_FILE']                 = "#{PROJECT_NAME}/Info.plist"
  config.build_settings['SWIFT_EMIT_LOC_STRINGS']         = 'YES'
  config.build_settings['ENABLE_PREVIEWS']                = 'YES'
  config.build_settings['DEVELOPMENT_TEAM']               = TEAM_ID unless TEAM_ID.empty?
  config.build_settings['CODE_SIGN_STYLE']                = 'Automatic'
  config.build_settings['ASSETCATALOG_COMPILER_APPICON_NAME'] = 'AppIcon'
end

debug_config&.build_settings&.merge!({
  'DEBUG_INFORMATION_FORMAT'   => 'dwarf',
  'ONLY_ACTIVE_ARCH'           => 'YES',
  'SWIFT_OPTIMIZATION_LEVEL'   => '-Onone',
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS' => 'DEBUG',
})

release_config&.build_settings&.merge!({
  'DEBUG_INFORMATION_FORMAT'   => 'dwarf-with-dsym',
  'SWIFT_OPTIMIZATION_LEVEL'   => '-O',
  'VALIDATE_PRODUCT'           => 'YES',
})

# Project-level build settings
project.build_configurations.each do |config|
  config.build_settings['ALWAYS_SEARCH_USER_PATHS'] = 'NO'
end

project.save

puts "✅ #{project_path} generated successfully!"
puts "📂 Open with: open #{project_path}"
