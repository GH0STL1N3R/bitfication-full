class MyFPM

  attr_accessor :name, :version, :dependencies, :files, :exclude
  attr_accessor :destination, :description, :vendor, :maintainer, :post_install

  def initialize(name, version)
    @name = name
    @version = version
    @dependencies = []
    @files = []
    @exclude = []
    @description = ''
    @vendor = ''
    @maintainer = ''
  end

  def package!
    `#{fpm_cmd}`

    raise Exception.new('Failure to generate package :(') unless $?.success?
  end

  private

  def pack_files
    (@files - @exclude).join(' ')
  end

  def fpm_cmd
    cmd = "fpm -s dir -t deb -n #{@name} -v #{@version} -a all --prefix #{@destination}"
    cmd += " --vendor #{@vendor}" unless @vendor.nil?
    cmd += " --description '#{@description}'" unless @description.nil?
    cmd += " -m #{@maintainer}" unless @maintainer.nil?
    cmd += " -d '#{@dependencies.join('\',\'')}' " if @dependencies.any?
    cmd += " --exclude #{@exclude.join(' --exclude ')}" if @exclude.any?
    cmd += " --after-install #{@post_install}" unless @post_install.nil?
    cmd += " #{pack_files}"

    puts "Generating package:\n#{cmd}"

    cmd
  end
end

task :package, [:version, :includes, :excludes] do |t, args|

  if args.version.nil?
    abort "Need to pass at least the version to package.\nUsage: rake package['version', 'opt. files to include', opt. files to exclude']"
  end

  fpm = MyFPM.new('bitfication', args.version)
  fpm.destination = '/opt/bitfication'

  opt_files = args.includes.nil? ? [] : args.includes.split(' ')
  opt_excludes = args.excludes.nil? ? [] : args.excludes.split(' ')

  fpm.files = Dir['*'] + opt_files
  fpm.exclude = ['spec'] + opt_excludes

  fpm.dependencies = [ 'ruby', 'rails', 'bundler', 'unicorn', 'ruby-jquery-rails', 'ruby-mysql2', 'ruby-will-paginate' ]

  fpm.post_install = './misc/postinstall.sh'

  fpm.vendor = 'Bitfication'
  fpm.maintainer = 'thiago@bitfication.com'
  fpm.description = 'Bitfication, a Open Source CryptoCurrency Exchange'

  fpm.package!

end
