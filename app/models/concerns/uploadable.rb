require 'fileutils'

module Uploadable
    extend ActiveSupport::Concern

    included do
        before_destroy :delete_code_locations
        validate :file_location_exists
    end

    def upload=(uploaded_io)
        unless self.name.blank?
            random_hex = SecureRandom.hex
            self.file_location = '' if self.file_location.nil?
            delete_code(self.file_location)
            self.file_location = store_file(uploaded_io, self.class.to_s.downcase.pluralize, random_hex)[:file]
            uncompress(self.contest.referee.compressed_file_location, File.dirname(self.file_location)) if self.class == Player 
        end
    end

    def upload2=(uploaded_io)
        unless self.name.blank?
            random_hex = SecureRandom.hex
            self.compressed_file_location = '' if self.compressed_file_location.nil?
            delete_code(self.compressed_file_location)
            self.compressed_file_location = store_file(uploaded_io, 'environments', random_hex)[:file]
        end
    end

    def upload3=(uploaded_io)
        unless self.name.blank?
            random_hex = SecureRandom.hex
            self.replay_assets_location = '' if self.replay_assets_location.nil?
            delete_code(self.replay_assets_location)
            self.replay_assets_location = store_file(uploaded_io, File.join("static", self.class.to_s.downcase.pluralize), random_hex)[:directory]
        end
    end


    #def compressed_file_location_exists
    #   if self.compressed_file_location.nil? || !File.exists?(self.compressed_file_location)
    #	errors.add(:compressed_file_location, "doesn't exist on the server")
    #   end
    #end 
    def file_location_exists
        if self.file_location.nil? || !File.exists?(self.file_location)
            errors.add(:file_location, "doesn't exist on the server")
        end
    end

    private

    def delete_code_locations

        delete_code(self.file_location) 
        delete_code(self.compressed_file_location) if (self.has_attribute?(:compressed_file_location) && !self.compressed_file_location.nil?)
        delete_code(self.replay_assets_location) if (self.has_attribute?(:replay_assets_location) && !self.replay_assets_location.nil?)

    end

    #Delete directory where file is located
    def delete_code(location)
        pathname = Pathname.new(location)
        if not pathname.directory?
            location = pathname.dirname
        end
        FileUtils.rm_rf(location) if pathname.exist?
        if pathname.exist? 
            raise "Deleting stuff it shouldnt"
        end
    end

    def store_file(uploaded_io, dir, random_hex)
        file_location = ''
        dir_location = ''
        unless uploaded_io.nil?
            dir_location = Rails.root.join('code', dir, Rails.env, random_hex)
            file_location = dir_location.join(self.name).to_s
            dir_location = dir_location.to_s
            FileUtils.mkdir_p dir_location
            IO.copy_stream(uploaded_io, file_location)
            uncompress(file_location, dir_location)
        end
        {file: file_location, directory: dir_location}
    end

    def uncompress(src, dest)
        system("tar -xvf #{src} -C #{dest} > /dev/null 2>&1") 
        system("unzip #{src} -d #{dest} > /dev/null 2>&1")
        system("chmod +x #{dest}/*")
        system("dos2unix -q #{dest}/*")
    end
end

