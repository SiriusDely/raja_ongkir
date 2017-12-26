lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'raja_ongkir/version'

# class Gem::Specification
#   def check_allowed_push_host
#     # Prevent pushing this gem to RubyGems.org.
#     # To allow pushes either set the 'allowed_push_host'
#     # to allow pushing to a single host or delete this section
#     # to allow pushing to any host.
#     if respond_to?(:metadata)
#       metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
#     else
#       raise 'RubyGems 2.0 or newer is required to protect against ' \
#         'public gem pushes.'
#     end
#   end
# end

Gem::Specification.class_exec do
  def check_allowed_push_host
    # Prevent pushing this gem to RubyGems.org.
    # To allow pushes either set the 'allowed_push_host'
    # to allow pushing to a single host or delete this section
    # to allow pushing to any host.
    if respond_to?(:metadata)
      metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
    else
      raise 'RubyGems 2.0 or newer is required to protect against ' \
        'public gem pushes.'
    end
  end
end

Gem::Specification.new do |spec|
  spec.name          = 'raja_ongkir'
  spec.version       = RajaOngkir::VERSION
  spec.authors       = ['Sirius Dely']
  spec.email         = ['siriusdely@icloud.com']

  spec.summary       = 'Client for rajaongkir.com'
  spec.description   = 'Client for rajaongkir.com'
  spec.homepage      = 'https://github.com/siriusdely/raja_ongkir'
  spec.license       = 'MIT'

  spec.check_allowed_push_host

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.13'
  spec.add_development_dependency 'coveralls', '~> 0.8'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rubocop', '~> 0.49'
  spec.add_runtime_dependency 'httparty', '~> 0.15'
end
