#encoding:utf-8
#==============================================================================
# ■ Cache
#------------------------------------------------------------------------------
#  此模块载入所有图像，建立并保存 Bitmap 对象。为加快载入速度并节省内存，
#  此模块将以建立的 bitmap 对象保存在内部哈希表中，使得程序在需要已存在
#  的图像时能快速读取 bitmap 对象。
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # ● 获取动画图像
  #--------------------------------------------------------------------------
  def self.light(filename)
    load_bitmap("Graphics/Lights/", filename)
  end
end


#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　事件指令的解释器。
#   本类在 Game_Map、Game_Troop、Game_Event 类的内部使用。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 定义实例变量
  #--------------------------------------------------------------------------
  def set_player_light(light)
    set_light(light, $game_player)
  end
  def set_light(light, char = $game_map.events[@event_id])
    char.light = light
  end
  #--------------------------------------------------------------------------
  # ● 开启灯光遮罩效果
  #--------------------------------------------------------------------------
  def enable_light_mask(duration=10)
    $game_map.enable_light_mask(duration)
  end
  #--------------------------------------------------------------------------
  # ● 关闭灯光遮罩效果
  #--------------------------------------------------------------------------
  def disable_light_mask(duration=10)
    $game_map.disable_light_mask(duration)
  end
end

#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
#   添加了路径移动的地图人物类。
#   是 Game_Player、Game_Follower、GameVehicle、Game_Event 的父类。
#==============================================================================

class Game_Character < Game_CharacterBase
  attr_accessor :light
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　管理地图的类。拥有卷动地图以及判断通行度的功能。
#   本类的实例请参考 $game_map 。
#==============================================================================

class Game_Map
  attr_reader :light_mask
  attr_reader :light_mask_duration
  #--------------------------------------------------------------------------
  # ● 灯光遮罩层最大不透明度
  #--------------------------------------------------------------------------
  def light_mask_opacity
    return 255
  end
  #--------------------------------------------------------------------------
  # ● 开启灯光遮罩效果
  #--------------------------------------------------------------------------
  def enable_light_mask(duration)
    @light_mask = true
    @light_mask_duration = duration.to_i
  end
  #--------------------------------------------------------------------------
  # ● 关闭灯光遮罩效果
  #--------------------------------------------------------------------------
  def disable_light_mask(duration)
    @light_mask = false
    @light_mask_duration = duration.to_i
  end
end


#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　处理地图画面精灵和图块的类。本类在 Scene_Map 类的内部使用。
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● 初始化对象
  #--------------------------------------------------------------------------
  alias seal_test_initialize initialize
  def initialize
    seal_test_initialize
    create_light_mask
  end
  #--------------------------------------------------------------------------
  # ● 创建灯光遮罩sprite
  #--------------------------------------------------------------------------
  def create_light_mask
    viewport = Viewport.new
    viewport.z = @viewport1.z + 1
    @light_mask = Sprite.new(viewport)
    @light_mask.bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @light_mask.bitmap.fill_rect(
        0, 0, @light_mask.bitmap.width, @light_mask.bitmap.height, Color.new(255, 255, 255)
      )
    @light_mask.blend_type = 2
    @light_mask.opacity = 0
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  alias seal_test_update update
  def update
    seal_test_update
    update_light_mask
  end
  #--------------------------------------------------------------------------
  # ● 更新灯光遮罩
  #--------------------------------------------------------------------------
  def update_light_mask
    return if !@light_mask
    # 渐变打开灯光遮罩
    if $game_map.light_mask && @light_mask.opacity < $game_map.light_mask_opacity
      @light_mask.opacity += $game_map.light_mask_opacity / [$game_map.light_mask_duration, 1].max
    elsif !$game_map.light_mask && @light_mask.opacity > 0
      @light_mask.opacity -= $game_map.light_mask_opacity / [$game_map.light_mask_duration, 1].max
    end
    # 渲染灯光
    if @light_mask.opacity > 0
      @light_mask.bitmap.fill_rect(0, 0, @light_mask.bitmap.width, @light_mask.bitmap.height, Color.new(255, 255, 255)
      )
      for char in $game_map.events.values + [$game_player]
        if char.light
          bitmap = Cache.light(char.light)
          x = char.screen_x - bitmap.width / 2
          y = char.screen_y - 16 - bitmap.height / 2
          @light_mask.bitmap.blt(x, y, bitmap, Rect.new(0, 0, bitmap.width, bitmap.height))
        end
      end
    end
  end
end













