$:.unshift(File.dirname($0))

Dir.glob(File.join(File.dirname($0), 'test_*.rb')).each do |f|
  base = File.basename(f)
  if base != File.basename($0)
    require base
    puts(base)
  end
end
