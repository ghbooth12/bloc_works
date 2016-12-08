module BlocWorks
  def self.snake_case(camel_cased_word)
    string = camel_cased_word.gsub(/::/, '/')
    string.gsub!(/([A-Z]+)([A-Z][a-z])/, '\1_\2')  # CSVRead-NewFiles -> CSV_Read-NewFiles
    string.gsub!(/([a-z\d])([A-Z])/, '\1_\2')  # CSV_Read-NewFiles -> CSV_Read-New_Files
    string.tr!('-', '_')  # CSV_Read-New_Files -> CSV_Read_New_Files
    string.downcase
  end
end
