class Dir
  @@creation_number = 0

  # Creates a temp dir in location and performs the supplied code block
  def self.create_tmp_dir(name, location)
    @@creation_number += 1
    # This is to avoid a possible symlink attack vulnerability in the creation of temporary files.
    random_number = Kernel.rand(1000000000).to_s
    complete_dir_name = "#{location}/#{name}.#{Process.pid}.#{random_number}.#{@@creation_number}"

    mkdir(complete_dir_name)

    # Changing dirs must be done in a block. When you call chdir normally, really weird
    # stuff starts to happen. Functions fail silently, exceptions are ignored, etc...
    chdir(complete_dir_name) do
      begin
        yield
      ensure
        FileUtils.rmtree(["#{complete_dir_name}"])
      end
    end
  end
end
