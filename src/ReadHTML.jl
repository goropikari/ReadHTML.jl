module ReadHTML

using DataFrames, HTTP, Gumbo, AbstractTrees
export gettables, gettablerow, extractdata, makerowdata, read_html, read_table
const StrN = Union{String, Nothing}

# url 中の全ての <table>~</table> を抜き出す。
"""
    gettables(url::String)

Extract all <table>~</table> contents.
"""
function gettables(url::String)
    data = String(HTTP.get(url).body)
    data = replace(data, "\n"=>"")
    table_list = StrN[]
    offset = 1
    while true
        m = match(r"<table.*?>(.*?)</table>"s, data, offset)
        if isnothing(m)
            break
        else
            push!(table_list, m.match)
            offset = m.offset + 1
        end
    end
    return table_list
end

# 表中の全ての行を抜き出す
"""
    gettablerow(table)

Extract row data of table.
"""
function gettablerow(table, header)
    l = StrN[]
    offset = 1
    while true
        m = match(r"<tr.*?>(.*?)</tr>"s, table, offset)
        if isnothing(m)
            break
        else
            offset = m.offset + 1
            if header
                push!(l, m.captures[1])
            elseif !occursin(r"<th.*>", m.captures[1])
                push!(l, m.captures[1])
            end
        end
    end
    return l
end

function extractdata(data)
    data = replace(data, "\n"=>"")
    t = parsehtml(data)
    t = t.root[2]

    str = String[]
    for elem in PreOrderDFS(t)
        if isa(elem, HTMLText)
            push!(str, elem.text)
        end
    end
    return join(str)
end

function makerowdata(tr)
    l = StrN[]
    offset = 1
    while true
        m = match(r"<t[dh].*?>(.*?)</t[dh]>"s, tr, offset)
        if isnothing(m)
            break
        else
            offset = m.offset + 1
            push!(l, extractdata(m.match))
        end
    end
    return l
end

function read_table(table; header=true)
    containheader = occursin("</th>", table)
    trs = gettablerow(table, header)
    isempty(trs) && return nothing
    tr = trs[1]
    ncol = makerowdata(tr) |> length # Obtain the # of cols
    nrow = size(trs, 1)
    arr = Matrix{StrN}(undef, nrow, ncol)
    for (rowidx, tr) in enumerate(trs)
        rowdata = makerowdata(tr)
        for (colidx, colitem) in enumerate(rowdata)
            arr[rowidx, colidx] = colitem
        end
    end
    try
        if containheader && header
            DataFrame(arr[2:end, :], Symbol.(arr[1,:]))
        else
            DataFrame(arr)
        end
    catch
    end
end

function read_html(url; header=true)
    tables = gettables(url)
    dfs = DataFrame[]
    for table in tables
        tb = read_table(table, header=header)
        !isnothing(tb) && push!(dfs, tb)
    end
    return dfs
end

end # module
