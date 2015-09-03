=begin

InputFocus
Author: leav

功能：
解除使用Input的对象之间的耦合，让每个对象管理自己的焦点，
而不必知道其他对象的激活情况

应用：
自制UI，复杂的机关等

=end

module Input
  class << self
    #--------------------------------------------------------------------------
    # ● 返回焦点堆栈
    #--------------------------------------------------------------------------
    def get_focus_stack
      return @focus_stack || @focus_stack = []
    end
    #--------------------------------------------------------------------------
    # ● 返回object是否处于焦点
    #--------------------------------------------------------------------------
    def focus?(object)
      focus = self.get_focus_stack.last
      return focus == nil || focus == object
    end
    #--------------------------------------------------------------------------
    # ● 焦点object
    #--------------------------------------------------------------------------
    def focus(object)
      raise "Input.focus() cannot have nil parameter" if object == nil
      unfocus(object)
      get_focus_stack.push(object)
    end
    #--------------------------------------------------------------------------
    # ● 取消object焦点
    #--------------------------------------------------------------------------
    def unfocus(object)
      raise "Input.unfocus() cannot have nil parameter" if object == nil
      get_focus_stack.reject! do |item|
        item == object
      end
    end
    #--------------------------------------------------------------------------
    # ● 重定义Input方法
    #    Input只会对处于焦点的对象有响应
    #--------------------------------------------------------------------------    
    if @input_focus_old_defined == nil
      %w[press? trigger? repeat?].each do |symbol|
        eval("
          alias :input_focus_old_#{symbol} :#{symbol}
          def #{symbol}(key, object = nil)
            if focus?(object)
              return input_focus_old_#{symbol}(key)
            else
              return false
            end
          end
        ")
      end
      %w[dir4 dir8].each do |symbol|
        eval("
          alias :input_focus_old_#{symbol}  :#{symbol}
          def #{symbol}(object = nil)
            if focus?(object)
              return input_focus_old_#{symbol}()
            else
              return 0
            end
          end
        ")
      end
      @input_focus_old_defined = true
    end
  end
end