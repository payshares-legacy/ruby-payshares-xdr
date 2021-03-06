require 'base64'

class XDR::Struct
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  extend XDR::Concerns::ConvertsToXDR
  extend XDR::DSL::Struct

  class_attribute :fields
  self.fields = ActiveSupport::OrderedHash.new

  validates_with XDR::StructValidator

  def self.read(io)
    new.tap do |result|
      fields.each do |name, type|
        result.public_send("#{name}=", type.read(io))
      end
    end
  end

  def self.write(val, io)
    fields.each do |name, type|
      field_val = val.public_send(name)
      type.write(field_val, io)
    end
  end
  
  def self.valid?(val)
    val.is_a?(self)
  end

  # 
  # Serializes struct to xdr, return a string of bytes
  # 
  # @param format=:raw [Symbol] The encoding used for the bytes produces, one of (:raw, :hex, :base64)
  # 
  # @return [String] The encoded bytes of this struct
  def to_xdr(format=:raw)
    raw = self.class.to_xdr(self)

    case format
    when :raw ;     raw
    when :hex ;     raw.unpack("H*").first
    when :base64 ;  Base64.strict_encode64(raw)
    else ; 
      raise ArgumentError, "Invalid format #{format.inspect}; must be :raw, :hex, or :base64"
    end
  end
end