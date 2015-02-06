class XDR::Union
  include ActiveModel::Model
  include ActiveModel::AttributeMethods

  extend XDR::Concerns::ConvertsToXDR
  extend XDR::DSL::Union


  class_attribute :arms
  class_attribute :switches
  class_attribute :switch_type
  class_attribute :switch_name
  attr_reader     :switch
  attr_reader     :arm

  self.arms        = ActiveSupport::OrderedHash.new
  self.switches    = ActiveSupport::OrderedHash.new
  self.switch_type = nil
  self.switch_name = nil

  attribute_method_suffix '!'

  validates_with XDR::UnionValidator

  def self.arm_for_switch(switch)
    result = switches.fetch(switch, :switch_not_found)
    result = switches.fetch(:default, :switch_not_found) if result == :switch_not_found

    if result == :switch_not_found
      raise XDR::InvalidSwitchError, "Bad switch: #{switch.inspect}"
    end

    result
  end

  def self.read(io)
    switch   = XDR::Int.read(io)
    arm      = arm_for_switch(switch)
    arm_type = arms[arm] || XDR::Void
    value    = arm_type.read(io)
    new(switch, value)
  end

  def self.write(val, io)
    XDR::Int.write(val.switch, io)
    arm_type = arms[val.arm] || XDR::Void
    arm_type.write(val.get,io)
  end

  def initialize(switch=nil, value=:void)
    @switch   = nil
    @arm      = nil
    @value    = nil
    set(switch, value) if switch
  end

  def to_xdr
    self.class.to_xdr self
  end

  def set(switch, value=:void)
    @switch = switch.is_a?(Fixnum) ? switch : switch_type.from_name(switch)
    @arm    = self.class.arm_for_switch @switch

    raise XDR::InvalidValueError unless valid_for_arm_type(value, @arm)

    @value = value
  end

  def get
    @value
  end

  def attribute!(attr)
    if @arm.to_s != attr
      raise XDR::ArmNotSetError, "#{attr} is not the set arm"
    end

    get
  end

  private
  def valid_for_arm_type(value, arm)
    arm_type = arms[@arm]

    case arm_type
    when nil
      value == :void
    when XDR::Int, XDR::UnsignedInt, XDR::Hyper, XDR::UnsignedHyper ;
      value.is_a?(Fixnum)
    when XDR::Float, XDR::Double, XDR::Quadruple ;
      value.is_a?(Float)
    when XDR::String, XDR::Opaque, XDR::VarOpaque ;
      value.is_a?(String)
    when XDR::Array, XDR::VarArray ;
      value.is_a?(Array)
    when XDR::Bool ;
      value.is_a?(Boolean)
    when XDR::Option ;
      value.nil? || valid_for_arm_type(value, arm_type.child_type)
    else

      # if none of the above special cases, the value needs to be descendent
      # from the arm_type

      value.is_a?(arm_type)
    end
  end
end



