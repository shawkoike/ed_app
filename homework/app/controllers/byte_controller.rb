class ByteController < ApplicationController
  def yarv
  end
  
  def byte_yarv
    @code = params[:yarv]
    @title = "YARV 命令列"
    @yarv = Array.new
    @yarv = RubyVM::InstructionSequence.compile(@code).disasm.split(/\n/)
    render action: :yarv
  end
end
