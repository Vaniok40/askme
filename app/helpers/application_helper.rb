module ApplicationHelper
  MONTHS_RO = %w[ianuarie februarie martie aprilie mai iunie iulie august septembrie octombrie noiembrie decembrie].freeze

  def ro_date(date)
    "#{date.day} #{MONTHS_RO[date.month - 1]} #{date.year}"
  end

  def ro_month_year(date)
    "#{MONTHS_RO[date.month - 1].capitalize} #{date.year}"
  end

  AVATAR_COLORS = %w[
    #3a5c8c #1a6b4a #7b3f00 #5c0a5a #0a4a5c
    #3a5c1a #5c3a1a #1a3a5c #5c1a3a #402E2A
    #2d6a4f #6a2d2d #2d4a6a #6a5a2d #4a2d6a
  ].freeze

  def fa_icon(icon_class)
    content_tag 'span', '', class: "fa fa-#{icon_class}"
  end

  def display_avatar(user)
    name_in_array = user.name.split(' ')

    return "#{name_in_array[0][0].upcase}#{name_in_array[1][0].upcase}" if name_in_array.size > 1

    user.name[0].upcase
  end

  def avatar_color(user)
    AVATAR_COLORS[user.username.bytes.sum % AVATAR_COLORS.length]
  end
end
