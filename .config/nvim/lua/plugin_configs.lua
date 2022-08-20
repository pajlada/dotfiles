local utils = require("config.utils")
local autocmd = utils.autocmd
local map = utils.map

-- graphviz (liuchengxu/graphviz.vim)
-- Compile .dot-files to png
vim.g.graphviz_output_format = "png"

-- Open Graphviz results with sxiv
vim.g.graphviz_viewer = "sxiv"

-- Automatically compile dot files when saving
-- XXX: For some reason, setting the output format is not respected so I need to specify png here too
autocmd("graphviz_autocompile", {
    [[BufWritePost *.dot GraphvizCompile png]],
}, true)
