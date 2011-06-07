class Hash
  
  # http://stackoverflow.com/questions/4157399/how-do-i-copy-a-hash-in-ruby
  def deep_copy
    Marshal.load(Marshal.dump(self))
  end
  
end
