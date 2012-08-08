class RSpecDescribeHandler < YARD::Handlers::Ruby::Base
  handles method_call(:describe)
  
  def process
    objname = statement.parameters.first.jump(:string_content).source
    if statement.parameters[1]
      src = statement.parameters[1].jump(:string_content).source
      objname += (src[0] == "#" ? "" : "::") + src
    end
    obj = {:spec => owner ? (owner[:spec] || "") : ""}
    obj[:spec] += objname.gsub(/^\./,'#')
    parse_block(statement.last.last, owner: obj)
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecContextHandler < YARD::Handlers::Ruby::Base
  handles method_call(:context)
  
  def process
    if owner
      owner[:context] ||= []
      owner[:context] << statement.parameters.first.jump(:string_content).source
    end
    r = parse_block(statement.last.last, owner: owner)
    owner[:context].pop if owner
    r
  rescue YARD::Handlers::NamespaceMissingError
  end
end

class RSpecItHandler < YARD::Handlers::Ruby::Base
  handles method_call(:it)
  
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
    
    name = statement.parameters.first.jump(:string_content).source
    
    ob[:all] << {
        name: name,
        file: statement.file,
        line: statement.line,
        source: statement.last.last.source.chomp
      }
    obj[:specifications]
  end
end
