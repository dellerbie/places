module Places
  module SpecHelper
    def overwrites_file?(file)
      yield
      first_time = File.mtime(file)
      sleep 1
      yield
      second_time = File.mtime(file)
      first_time != second_time
    end
  end
end