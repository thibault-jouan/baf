directories %w[features lib spec]

guard :cucumber, cmd_additional_args: '--profile guard', all_on_start: false do
  watch(%r{\Afeatures/.+\.feature\z})
end

guard :rspec, cmd: 'rspec -f doc' do
  watch(%r{\Aspec/.+_spec\.rb\z})
  watch(%r{\Alib/(.+)\.rb\z})     { |m| "spec/#{m[1]}_spec.rb" }
end
