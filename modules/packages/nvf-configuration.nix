{ inputs, ... }:
{
  flake.flakeModules.nvf-config =
    { pkgs, lib, ... }:
    {
      vim = {
        globals = {
          editorconfig = true;
          mapleaders = " ";
          maplocalleader = " ";
        };
        options = {
          backup = false;
          clipboard = "unnamedplus";
          completeopt = [
            "menuone"
            "noselect"
          ];
          conceallevel = 0;
          fileencoding = "utf-8";
          hlsearch = true;
          ignorecase = true;
          mouse = "a";
          pumheight = 10;
          showmode = false;
          showtabline = 2;
          smartcase = true;
          splitbelow = true;
          splitright = true;
          swapfile = false;
          termguicolors = true;
          timeoutlen = 300;
          undofile = true;
          updatetime = 300;
          writebackup = false;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          cursorline = true;
          number = true;
          relativenumber = true;
          numberwidth = 4;
          signcolumn = "yes";
          wrap = true;
          linebreak = true;
          scrolloff = 8;
          sidescrolloff = 8;
          guifont = "monospace:h17";
          whichwrap = "bs<>[]hl";
          winborder = "rounded";
        };
        keymaps = [
          {
            key = "<leader>h";
            mode = "n";
            silent = false;
            desc = "Move to the left window";
            action = "<C-w>h";
          }
          {
            key = "<leader>j";
            mode = "n";
            silent = false;
            desc = "Move to the upper window";
            action = "<C-w>j";
          }
          {
            key = "<leader>k";
            mode = "n";
            silent = false;
            desc = "Move to the down window";
            action = "<C-w>k";
          }
          {
            key = "<leader>l";
            mode = "n";
            silent = false;
            desc = "Move to the right window";
            action = "<C-w>l";
          }
          {

            key = "";
            mode = "";
            silent = "";
            desc = "";
          }
        ];
        theme = {
          enbable = true;
          name = "tokyonight";
          style = "storm";
        };

        statusline.lualine.enable = true;
        telescope.enable = true;
        autocomplete.nvim-cmp.enable = true;

        languages = {
          enableLSP = true;
          enableTreesitter = true;

          nix.enable = true;
        };

      };
    };
}
