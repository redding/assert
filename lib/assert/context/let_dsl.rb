module Assert; end
class Assert::Context; end
module Assert::Context::LetDSL
  def let(name, &block)
    self.send(:define_method, name, &-> {
      if instance_variable_get("@#{name}").nil?
        instance_variable_set("@#{name}", instance_eval(&block))
      end

      instance_variable_get("@#{name}")
    })
  end
end
