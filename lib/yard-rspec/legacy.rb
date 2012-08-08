class LegacyRSpecDescribeHandler < YARD::Handlers::Ruby::Legacy::Base
  MATCH = /\Adescribe\s+(.+?)\s+(do|\{)/
  handles MATCH

  def process
    objname = statement.tokens.to_s[MATCH, 1].gsub(/["']/, '')
    objname.sub!(/^\./,'#')
    obj = {:spec => owner ? (owner[:spec] || "") : ""}
    obj[:spec] += objname
    parse_block :owner => obj
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class LegacyRSpecContextHandler < YARD::Handlers::Ruby::Legacy::Base
  MATCH = /\Acontext\s+(.+?)\s+(do|\{)/
  handles MATCH

  def process
    if owner
      owner[:context] ||= []
      owner[:context] << statement.tokens.to_s[MATCH, 1].gsub(/["']/, '')
    end
    r = parse_block :owner => owner
    owner[:context].pop if owner
    r
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class LegacyRSpecItHandler < YARD::Handlers::Ruby::Legacy::Base
  MATCH = /\Ait\s+['"](.+?)['"]\s+(do|\{)/
  handles MATCH

  def process
    return if owner.nil?
    obj = P(owner[:spec])
    return if obj.is_a?(Proxy)

    context = owner[:context]||[]

    obj[:specifications] ||= {}
    obj[:specifications][:all] ||= []
    ob = obj[:specifications]
    context.each do |co|
      ob[co] ||= {}
      ob[co][:all] ||= []
      ob = ob[co]
    end

    ob[:all] << {
      :name => statement.tokens.to_s[MATCH, 1],
      :file => parser.file,
      :line => statement.line,
      :source => statement.block.to_s
    }
    obj[:specifications]
  end
end

