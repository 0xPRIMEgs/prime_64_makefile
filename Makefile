# Shared libdragon workspace
#
# Default:
#   libdragon make
#
# Another project:
#   libdragon make PROJECT=xentank
#
# The selected project provides:
#   <project>/src/
#   <project>/assets/
#
# Generated files stay at workspace root:
#   build/
#   filesystem/
#   <project>.z64

PROJECT ?= platformer

BUILD_DIR := build
SOURCE_DIR := $(PROJECT)/src
ASSET_DIR := $(PROJECT)/assets
N64_MKDFS_ROOT := filesystem

.DEFAULT_GOAL := all

include $(N64_INST)/include/n64.mk

# ------------------------------------------------------------
# Source
# ------------------------------------------------------------

# main.c directly includes prime_fps_64.c and prime_renderer_64.c,
# so only compile main.c as its own translation unit.
src := $(SOURCE_DIR)/main.c
objects := $(BUILD_DIR)/main.o

# ------------------------------------------------------------
# Assets
# ------------------------------------------------------------

assets_png := $(wildcard $(ASSET_DIR)/*.png)
assets_sprite := $(patsubst $(ASSET_DIR)/%.png,filesystem/%.sprite,$(assets_png))

assets_wav := $(wildcard $(ASSET_DIR)/*.wav)
assets_wav64 := $(patsubst $(ASSET_DIR)/%.wav,filesystem/%.wav64,$(assets_wav))

# Optional subdirectories retained for XenTank.
tilemap_png := $(wildcard \
	$(ASSET_DIR)/tilemap_forest/*.png \
	$(ASSET_DIR)/tilemap_caves/*.png \
	$(ASSET_DIR)/tilemap_mines/*.png \
	$(ASSET_DIR)/tilemap_ruins/*.png)

tilemap_sprite := $(patsubst $(ASSET_DIR)/%.png,filesystem/%.sprite,$(tilemap_png))

tone_wav := $(wildcard $(ASSET_DIR)/prime_midi64_tones/*.wav)
tone_wav64 := $(patsubst $(ASSET_DIR)/%.wav,filesystem/%.wav64,$(tone_wav))

map_txt := $(wildcard $(ASSET_DIR)/maps/*.txt)
enemy_txt := $(wildcard $(ASSET_DIR)/enemies/*.txt)
data_txt := $(map_txt) $(enemy_txt)
data_files := $(patsubst $(ASSET_DIR)/%,filesystem/%,$(data_txt))

filesystem_assets := \
	$(assets_sprite) \
	$(assets_wav64) \
	$(tilemap_sprite) \
	$(tone_wav64) \
	$(data_files)

MKSPRITE_FLAGS ?=

# ------------------------------------------------------------
# Main build
# ------------------------------------------------------------

all: $(PROJECT).z64

# n64.mk compiles build/foo.o from $(SOURCE_DIR)/foo.c.
$(BUILD_DIR)/$(PROJECT).elf: $(objects)

# Build the filesystem before n64.mk invokes mkdfs.
$(BUILD_DIR)/$(PROJECT).dfs: $(filesystem_assets)

$(PROJECT).z64: N64_ROM_TITLE="$(PROJECT)"
$(PROJECT).z64: $(BUILD_DIR)/$(PROJECT).dfs

# ------------------------------------------------------------
# Asset conversion
# ------------------------------------------------------------

filesystem/%.sprite: $(ASSET_DIR)/%.png
	@mkdir -p "$(dir $@)"
	@echo "    [SPRITE] $@"
	@$(N64_MKSPRITE) -f RGBA16 $(MKSPRITE_FLAGS) -o "$(dir $@)" "$<"

filesystem/%.wav64: $(ASSET_DIR)/%.wav
	@mkdir -p "$(dir $@)"
	@echo "    [WAV64] $@"
	@$(N64_AUDIOCONV) -o "$(dir $@)" "$<"

filesystem/%.txt: $(ASSET_DIR)/%.txt
	@mkdir -p "$(dir $@)"
	@echo "    [DATA] $@"
	@cp "$<" "$@"

# ------------------------------------------------------------
# Utility
# ------------------------------------------------------------

info:
	@echo "PROJECT        = $(PROJECT)"
	@echo "SOURCE_DIR     = $(SOURCE_DIR)"
	@echo "ASSET_DIR      = $(ASSET_DIR)"
	@echo "BUILD_DIR      = $(BUILD_DIR)"
	@echo "N64_MKDFS_ROOT = $(N64_MKDFS_ROOT)"
	@echo "ROM            = $(PROJECT).z64"
	@echo "SOURCES        = $(src)"
	@echo "OBJECTS        = $(objects)"
	@echo "ASSETS         = $(filesystem_assets)"

clean:
	rm -rf "$(BUILD_DIR)" filesystem "$(PROJECT).z64"

-include $(wildcard $(BUILD_DIR)/*.d)

.PHONY: all clean info
