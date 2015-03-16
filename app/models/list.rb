class List
    include MongoMapper::Document

    key :email,     String, :unique => true
    key :name,      String

    timestamps!
end