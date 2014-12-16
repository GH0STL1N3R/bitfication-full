class MyFPM
  attr_accessor :name, :version, :dependencies, :files, :exclude, :destination, :description, :vendor, :maintainer

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
    cmd += " --vendor #{@vendor}" if @vendor.present?
    cmd += " --description '#{@description}'" if @description.present?
    cmd += " -m #{@maintainer}" if @maintainer.present?
    cmd += " -d '#{@dependencies.join('\',\'')}' " if @dependencies.any?
    cmd += " --exclude #{@exclude.join(' --exclude ')}" if @exclude.any?
    cmd += " #{pack_files}"

    puts "Generating package:\n#{cmd}"

    cmd
  end
end

task :package, [:version, :includes, :excludes] do |t, args|
  if args.empty?
    abort "Needs to pass almost a version to package.\nUsage: rake package['version', 'opt. files to include', opt. files to exclude']"
  end

  fpm = MyFPM.new('bitfication', args.version)
  fpm.destination = '/opt/bitfication'

  opt_files = args.includes.present? ? args.includes.split(' ') : [ ]
  opt_excludes = args.excludes.present? ? args.excludes.split(' ') : [ ]

  fpm.files = Dir['*'] + opt_files
  fpm.exclude = ['test', 'spec', 'tmp', 'log'] + opt_excludes
  fpm.dependencies = [ 'apache2', 'ruby', 'rails' ]
  fpm.vendor = 'Bitfication'
  fpm.maintainer = 'thiagocmartinsc@gmail.com'
  fpm.description = 'Bitfication CryptoCurrency Open Source Exchange'

  fpm.package!
end
