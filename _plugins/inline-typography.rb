# frozen_string_literal: true

# Inline typography extensions for the kramdown/GFM pipeline:
#
#   ==highlight==  -> <mark>highlight</mark>
#   H~2~O          -> H<sub>2</sub>O
#   X^2^           -> X<sup>2</sup>
#
# Runs on the final HTML (:post_render). Code regions (<pre>/<code>/<kbd>,
# <script>/<style>) and MathJax source text are protected so neither source
# code nor formulas are ever rewritten.

module InlineTypography
  CODE_REGIONS = %r{(<(?<tag>pre|code|kbd|script|style)\b[^>]*>.*?</\k<tag>>)}m.freeze

  # MathJax source must stay untouched: \(...\) / \[...\] emitted by kramdown,
  # and single-dollar inline math that passes through verbatim.
  MATH_REGIONS = %r{(\\\[[\s\S]*?\\\]|\\\([\s\S]*?\\\)|\$[^$\n]+\$)}m.freeze

  PLACEHOLDER = "\x00"

  # Body rules: the wrapped content must not contain the delimiter, `<` (so
  # matches never walk across tags) or newlines (to stay inside one line).
  MARK = /==(?<body>[^=\n<]+?)==/m.freeze
  SUB = /~(?<body>[^~\s<](?:[^~\n<]*?[^\s~<])?)~/m.freeze
  SUP = /\^(?<body>[^^\s<](?:[^^\n<]*?[^\s^<])?)\^/m.freeze

  def self.convert(html)
    segments = []
    html = html.gsub(CODE_REGIONS) do |segment|
      take(segment, segments)
    end
    html = html.gsub(MATH_REGIONS) do |segment|
      take(segment, segments)
    end

    html = html
           .gsub(MARK, '<mark>\k<body></mark>')
           .gsub(SUB, '<sub>\k<body></sub>')
           .gsub(SUP, '<sup>\k<body></sup>')

    html.gsub(/#{PLACEHOLDER}(\d+)#{PLACEHOLDER}/) do
      segments[Regexp.last_match(1).to_i]
    end
  end

  def self.take(segment, segments)
    segments << segment
    "#{PLACEHOLDER}#{segments.length - 1}#{PLACEHOLDER}"
  end
  private_class_method :take
end

Jekyll::Hooks.register %i[posts pages tabs], :post_render do |doc|
  doc.output = InlineTypography.convert(doc.output)
end