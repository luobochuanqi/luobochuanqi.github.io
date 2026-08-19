# frozen_string_literal: true

# GitHub-style alerts (https://docs.github.com/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#alerts)
# for the kramdown/GFM pipeline.
#
# kramdown has no admonition syntax, so `> [!NOTE]` etc. render as plain
# blockquotes. This hook rewrites them (after layout rendering, when the HTML
# is final) into `<div class="alert alert-<type>">` containers.
#
# Supported source shapes (blank line between marker and body is the
# canonical GitHub form):
#
#   > [!NOTE]
#   >
#   > body                 -> default title (NOTE/TIP/...), body below
#
#   > [!TIP] Custom title
#   >
#   > body                 -> "Custom title" as the title
#
# A marker merged with body text (no blank line, e.g. `> [!NOTE] body`) is
# also accepted: the merged paragraph becomes the body and the default title
# is used, since kramdown cannot recover the title/body split afterwards.
#
# Nested blockquotes are converted inside-out, so alerts embedded in quotes
# or lists work as well.

module GfmAlerts
  TYPES = %w[NOTE TIP IMPORTANT WARNING CAUTION].freeze

  ICONS = {
    'NOTE' => 'fas fa-circle-info',
    'TIP' => 'fas fa-lightbulb',
    'IMPORTANT' => 'fas fa-circle-exclamation',
    'WARNING' => 'fas fa-triangle-exclamation',
    'CAUTION' => 'fas fa-bolt'
  }.freeze

  # Innermost <blockquote> (no nested <blockquote> inside).
  INNER_BLOCKQUOTE = %r{<blockquote\b[^>]*>((?:(?!</?blockquote\b).)*?)</blockquote>}m.freeze

  # First paragraph of the blockquote plus whatever follows it.
  FIRST_PARAGRAPH = %r{\A\s*<p>(?<head>.*?)</p>(?<rest>.*)\z}m.freeze

  MARKER = /\A\[!(?<type>#{TYPES.join('|')})\](?<tail>.*)\z/im.freeze

  def self.convert(html)
    html = html.dup
    loop do
      converted = html.gsub(INNER_BLOCKQUOTE) do |bq|
        build(Regexp.last_match(1)) || bq
      end
      break if converted == html

      html = converted
    end
    html
  end

  def self.build(content)
    m = content.match(FIRST_PARAGRAPH)
    return nil unless m

    head = m[:head]
    marker = head.match(MARKER)
    return nil unless marker

    type = marker[:type].upcase
    tail = marker[:tail].strip

    if tail.empty?
      # Bare marker: default title, the rest of the blockquote is the body.
      title = type
      body = m[:rest]
    elsif m[:rest].strip.empty?
      # Marker merged with body text in a single paragraph: treat it all as
      # body, the title/body split was lost during parsing.
      title = type
      body = "<p>#{tail}</p>"
    elsif m[:rest].match?(%r{\A\s*<p>})
      # Marker plus an explicit title on its own paragraph followed by body
      # paragraphs: the canonical form.
      title = tail
      body = m[:rest]
    else
      # Marker paragraph merged with body and followed by other blocks
      # (lists, quotes...): kramdown lost the title/body split, keep the
      # merged paragraph as body.
      title = type
      body = "<p>#{tail}</p>#{m[:rest]}"
    end

    title_html = %(<p class="alert-title"><i class="#{ICONS[type]}" aria-hidden="true"></i>#{title}</p>)
    %(<div class="alert alert-#{type.downcase}">#{title_html}#{body}</div>)
  end
end

Jekyll::Hooks.register %i[posts pages tabs], :post_render do |doc|
  doc.output = GfmAlerts.convert(doc.output) if doc.output.include?('[!')
end