{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    nixvim,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.${system};

      lspServers = {
        sqls = {
          enable = true;
        };
        verible = {
          enable = true;
        };
        gopls = {
          enable = true;
          settings = {
            gopls = {
              analyses = {unusedparams = true;};
              staticcheck = true;
            };
          };
        };
        ts_ls = {
          enable = true;
          filetypes = ["typescript" "javascript" "typescriptreact" "javascriptreact" "typescript.tsx"];
        };
        jsonls = {
          enable = true;
          settings = {
            json = {
              schemas = {
                "https://json.schemastore.org/package.json" = "package.json";
                "https://json.schemastore.org/tsconfig.json" = "tsconfig*.json";
              };
              validate = {enable = true;};
            };
          };
        };
        rust_analyzer = {
          enable = true;
          installCargo = true;
          installRustc = true;
          installRustfmt = true;
        };
        texlab = {
          enable = true;
        };
        clangd = {
          enable = true;
          extraOptions = {
            cmd = [
              "${lib.getExe' pkgs.clang-tools "clangd"}"
              "--fallback-style=llvm"
              "--enable-config"
              "--header-insertion=iwyu"
              "--clang-tidy"
              "--background-index"
            ];
            init_options.compilationDatabasePath = {
              lua = "vim.fn.getcwd()";
            };
          };
        };
        pylsp = {
          enable = true;
          settings = {
            plugins = {
              pycodestyle = {
                maxLineLength = 100;
              };
              pylint = {
                enabled = true;
              };
              rope_completion = {
                enabled = true;
              };
            };
          };
        };
        pyright = {
          enable = true;
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic";
                autoSearchPaths = true;
                useLibraryCodeForTypes = true;
                diagnosticMode = "workspace";
              };
            };
          };
        };
      };

      cmpSettings = {
        sources = [
          {name = "nvim_lsp";}
          {name = "path";}
          {name = "buffer";}
          {name = "luasnip";}
        ];
        mapping = {
          "<Down>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<Up>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
        };
      };

      nixvimConfig = {
        colorschemes.nightfox = {
          enable = true;
        };
        colorscheme = "carbonfox";
        extraPackages = [
          pkgs.alejandra
        ];
        plugins = {
          codesnap = {
            enable = true;
            settings = {
              save_path = "~/";
              mac_window_bar = false;
              title = "";
              watermark = "";
              breadcrumbs_separator = "/";
              has_breadcrumbs = true;
              has_line_number = true;
            };
          };
          vimtex = {
            enable = true;
            texlivePackage = pkgs.texlive.combined.scheme-full;
            settings = {
              view_method = "sioyek";
              compiler_method = "latexmk";
              compiler_latexmk = {
                continuous = 1;
                options = [
                  "-verbose"
                  "-file-line-error"
                  "-synctex=1"
                  "-interaction=nonstopmode"
                ];
              };
              quickfix_mode = 0;
              fold_enabled = 1;
            };
          };
          web-devicons.enable = true;
          lualine.enable = true;
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                enable = true;
                lspFallback = true;
              };
              formatters_by_ft = {
                nix = ["alejandra"];
              };
            };
          };
          telescope = {
            enable = true;
            settings.defaults = {
              selection_caret = " ";
              path_display = ["smart"];
              dynamic_preview_title = true;
              winblend = 0;
              sorting_strategy = "ascending";
              layout_strategy = "vertical";
              layout_config = {
                prompt_position = "bottom";
                height = 0.95;
                width = 0.8;
                preview_cutoff = 120;
                mirror = true;
              };
              file_ignore_patterns = [".git/"];
              mappings = {
                n = {
                  q = "close";
                  l = "select_default";
                };
                i = {
                  "<C-q>" = "smart_send_to_qflist";
                };
              };
            };
          };
          treesitter = {
            enable = true;
            nixGrammars = true;
          };
          harpoon = {
            enable = true;
            enableTelescope = true;
          };
          undotree.enable = true;
          fugitive.enable = true;
          mini-diff = {
            enable = true;
            settings = {
              view.style = "sign";
              mappings = {
                goto_first = "<leader>ggh";
                goto_next = "<leader>h";
                goto_prev = "<leader>H";
                goto_last = "<leader>Gh";
              };
            };
          };
          commentary.enable = true;
          vim-surround.enable = true;
          lsp = {
            enable = true;
            servers = lspServers;
          };
          luasnip.enable = true;
          cmp = {
            enable = true;
            autoEnableSources = true;
            settings = cmpSettings;
          };
          trouble = {
            enable = true;
            settings = {
              warn_no_results = false;
            };
          };
          todo-comments.enable = true;
        };
        globals.mapleader = " ";
        opts = {
          guicursor = "";
          number = true;
          relativenumber = true;
          tabstop = 4;
          softtabstop = 4;
          shiftwidth = 4;
          expandtab = true;
          smartindent = true;
          wrap = false;
          swapfile = false;
          backup = false;
          undofile = true;
          hlsearch = false;
          incsearch = true;
          termguicolors = true;
          scrolloff = 8;
          signcolumn = "yes";
          updatetime = 50;
          colorcolumn = "80";
        };
        keymaps = [
          {
            key = "-";
            action = ":Ex<CR>";
            mode = "n";
            options = {
              desc = "Open netrw";
              silent = true;
            };
          }
          {
            key = "gd";
            action.__raw = "require('telescope.builtin').lsp_definitions"; # Using telescope for better UI
            mode = "n";
            options = {
              desc = "Go to definition";
              silent = true;
            };
          }
          {
            key = "gr";
            action.__raw = "require('telescope.builtin').lsp_references";
            mode = "n";
            options = {
              desc = "Go to references";
              silent = true;
            };
          }
          {
            key = "K";
            action.__raw = "vim.lsp.buf.hover";
            mode = "n";
            options = {
              desc = "Show hover documentation";
              silent = true;
            };
          }
          {
            key = "<leader>rn";
            action.__raw = "vim.lsp.buf.rename";
            mode = "n";
            options = {
              desc = "Rename symbol";
              silent = true;
            };
          }
          {
            key = "<leader>pf";
            action.__raw = "require('telescope.builtin').find_files";
            mode = "n";
          }
          {
            key = "<C-p>";
            action.__raw = "require('telescope.builtin').git_files";
            mode = "n";
          }
          {
            key = "<leader>ps";
            action.__raw = "function() require('telescope.builtin').grep_string({search = vim.fn.input('Grep > ')}) end";
            mode = "n";
          }
          {
            key = "<leader>gs";
            action = ":Git<CR>";
            mode = "n";
          }
          {
            key = "<leader>gq";
            action.__raw = ''
              function()
                local items = {}
                for _, line in ipairs(vim.fn.systemlist({ "git", "status", "--short" })) do
                  local filename = vim.trim(string.sub(line, 4))
                  if filename ~= "" then
                    table.insert(items, {
                      filename = filename,
                      lnum = 1,
                      col = 1,
                      text = string.sub(line, 1, 2),
                    })
                  end
                end
                vim.fn.setqflist({}, "r", {
                  title = "Git changed files",
                  items = items,
                })
                vim.cmd("Trouble quickfix toggle")
              end
            '';
            mode = "n";
          }
          {
            key = "<leader>u";
            action = ":UndotreeToggle<CR>";
            mode = "n";
          }
          {
            key = "<leader>xx";
            action = ":Trouble diagnostics toggle<CR>";
            mode = "n";
            options = {
              desc = "Toggle trouble diagnostics";
            };
          }
          {
            key = "<leader>xd";
            action = ":Trouble diagnostics toggle filter.buf=0<CR>";
            mode = "n";
            options = {
              desc = "Toggle trouble document diagnostics";
            };
          }
          {
            key = "<leader>xq";
            action = ":Trouble quickfix toggle<CR>";
            mode = "n";
            options = {
              desc = "Toggle trouble quickfix list";
            };
          }
          {
            key = "<leader>xl";
            action = ":Trouble loclist toggle<CR>";
            mode = "n";
            options = {
              desc = "Toggle trouble location list";
            };
          }
          {
            key = "<leader>xt";
            action = ":Trouble todo toggle<CR>";
            mode = "n";
            options = {
              desc = "Toggle trouble todos list";
            };
          }
          {
            key = "<leader>pv";
            action = ":Ex<CR>";
            mode = "n";
          }
          {
            key = "J";
            action = ":m '>+1<CR>gv=gv";
            mode = "v";
          }
          {
            key = "K";
            action = ":m '<-2<CR>gv=gv";
            mode = "v";
          }
          {
            key = "J";
            action = "mzJ`z";
            mode = "n";
          }
          {
            key = "<C-d>";
            action = "<C-d>zz";
            mode = "n";
          }
          {
            key = "<C-u>";
            action = "<C-u>zz";
            mode = "n";
          }
          {
            key = "n";
            action = "nzzzv";
            mode = "n";
          }
          {
            key = "N";
            action = "Nzzzv";
            mode = "n";
          }
          {
            key = "<leader>p";
            action = "\"_dP";
            mode = "x";
          }
          {
            key = "<leader>y";
            action = "\"+y";
            mode = ["n" "v"];
          }
          {
            key = "<leader>Y";
            action = "\"+Y";
            mode = "n";
          }
          {
            key = "<leader>d";
            action = "\"_d";
            mode = ["n" "v"];
          }
          {
            key = "Q";
            action = "<nop>";
            mode = "n";
          }
          {
            key = "<leader>f";
            action.__raw = "function() require('conform').format({ lsp_fallback = true }) end";
            mode = "n";
            options = {
              desc = "Format buffer with conform (or LSP if no formatter)";
              silent = true;
            };
          }
          {
            key = "<C-k>";
            action = ":cnext<CR>zz";
            mode = "n";
          }
          {
            key = "<C-j>";
            action = ":cprev<CR>zz";
            mode = "n";
          }
          {
            key = "<leader>k";
            action = ":lnext<CR>zz";
            mode = "n";
          }
          {
            key = "<leader>j";
            action = ":lprev<CR>zz";
            mode = "n";
          }
          {
            key = "<leader>s";
            action = ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>";
            mode = "n";
          }
          {
            key = "<leader>x";
            action = ":!chmod +x %<CR>";
            mode = "n";
            options.silent = true;
          }
          {
            key = "<leader>bn";
            action = ":bnext<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>bp";
            action = ":bprevious<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>bd";
            action = ":bdelete<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>tt";
            action = ":tabnew %:p:h<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>tp";
            action = ":tabprev<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>tn";
            action = ":tabnext<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>tc";
            action = ":tabclose<CR>";
            mode = "n";
            options.noremap = true;
          }
          {
            key = "<leader>te";
            action = ":tabedit<Space>";
            mode = "n";
            options.noremap = true;
          }
        ];
        extraConfigVim = ''
          let g:netrw_banner = 0
          let g:netrw_list_hide = '^\./$,^\.\./$'
          set undodir=$HOME/.vim/undodir
          set isfname+=-
        '';
      };

      nixvimPackage = nixvim.legacyPackages.${system}.makeNixvim nixvimConfig;
    in {
      packages = {
        default = nixvimPackage;
        nixvim = nixvimPackage;
      };
    });
}
