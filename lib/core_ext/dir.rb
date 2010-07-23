class Dir
  @@creation_number = 0;

  # Creates a temp dir in location and performs the supplied code block
  def self.create_tmp_dir(name, location)
    @@creation_number += 1
    pid = Process.pid # This doesn't work on some platforms, according to the docs. A better way to get it would be nice.
    random_number = Kernel.rand(1000000000).to_s # This is to avoid a possible symlink attack vulnerability in the creation of temporary files.
    complete_dir_name = "#{location}/#{name}.#{pid}.#{random_number}.#{@@creation_number}"

    yield_result = Object.new

    self.mkdir(complete_dir_name)

    # Changing dirs must be done in a block. When you call chdir normally, really weird
    # stuff starts to happen. Functions fail silently, exceptions are ignored, etc...
    self.chdir(complete_dir_name) do
      begin
        yield_result = yield
      rescue
        raise
      ensure
        FileUtils.rmtree(["#{complete_dir_name}"])
      end
    end

    return yield_result
  end
end
