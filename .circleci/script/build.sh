#!/usr/bin/env bash
# shellcheck disable=SC2199
# shellcheck source=/dev/null
#
# Copyright (c) 2020 UtsavBalar1231 <utsavbalar1231@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

cd /home/circleci/project/kernel_realme_sdm710

# Export Cross Compiler name
	export COMPILER="ProtonClang-13.0"
# Export Build username
export KBUILD_BUILD_USER="Rmx1921"
export KBUILD_BUILD_HOST="circleci"

# Enviromental Variables
DATE=$(date +"%d.%m.%y")
HOME="/home/circleci/project/"
OUT_DIR=out/
if [[ "$@" =~ "lto"* ]]; then
	VERSION="SPIRA-${TYPE}-LTO${CIRCLE_BUILD_NUM}-${DATE}"
else
	VERSION="Spiral-${CIRCLE_BUILD_NUM}-${DATE}"
fi
BRANCH=`git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
KERNEL_LINK=https://github.com/Rmx1921/kernel_realme_sdm710.git
REF=`echo "$BRANCH" | grep -Eo "[^ /]+\$"`
AUTHOR=`git log $BRANCH -1 --format="%an"`
COMMIT=`git log $BRANCH -1 --format="%h / %s"`
MESSAGE="$AUTHOR@$REF: $KERNEL_LINK/commit/$COMMIT"
# Export Zip name
export ZIPNAME="${VERSION}.zip"

# How much kebabs we need? Kanged from @raphielscape :)
if [[ -z "${KEBABS}" ]]; then
	COUNT="$(grep -c '^processor' /proc/cpuinfo)"
	export KEBABS="$((COUNT * 2))"
fi

# Post to CI channel
#curl -s -X POST https://api.telegram.org/bot${BOT_API_KEY}/sendPhoto -d photo=https://github.com/UtsavBalar1231/xda-stuff/raw/master/banner.png -d chat_id=${CI_CHANNEL_ID}
curl -s -X POST https://api.telegram.org/bot1445481247:AAFmjxDbbXAEFjAgYdyeVj6ZKAq-obPV_64/sendMessage -d text="<code>𝕊ℙ𝕀ℝ𝔸𝕃</code>
Build: <code>${TYPE}</code>
Device: <code>Realme XT(RMX1921)</code>
Compiler: <code>${COMPILER}</code>
Branch: <code>$(git rev-parse --abbrev-ref HEAD)</code>
Commit: <code>$MESSAGE</code>
<i>Build started on Circle CI...</i>
Check the build status here: https://circleci.com/gh/Rmx1921/kernel_realme_sdm710/${CIRCLE_BUILD_NUM}" -d chat_id=338913217 -d parse_mode=HTML
curl -s -X POST https://api.telegram.org/bot1445481247:AAFmjxDbbXAEFjAgYdyeVj6ZKAq-obPV_64/sendMessage -d text="Build started for revision ${CIRCLE_BUILD_NUM}" -d chat_id=338913217 -d parse_mode=HTML

START=$(date +"%s")
	# Make defconfig
	make ARCH=arm64 \
		O=${OUT_DIR} \
		RMX1921_defconfig \
		-j${KEBABS}

	# Set compiler Path
	PATH=${HOME}/proton-clang/bin/:$PATH
	make ARCH=arm64 \
		O=${OUT_DIR} \
		CC="clang" \
		CLANG_TRIPLE="aarch64-linux-gnu-" \
		CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
		CROSS_COMPILE="aarch64-linux-gnu-" \
		-j${KEBABS}

END=$(date +"%s")
DIFF=$(( END - START))
# Import Anykernel3 folder
cd ..
cp ${HOME}/kernel_realme_sdm710/out/arch/arm64/boot/Image.gz-dtb ${HOME}/Anykernel/

cd Anykernel
zip -r9 ${ZIPNAME} * -x .git .gitignore *.zip
CHECKER=$(ls -l ${ZIPNAME} | awk '{print $5}')
if (($((CHECKER / 1048576)) > 5)); then
	curl -s -X POST https://api.telegram.org/bot1445481247:AAFmjxDbbXAEFjAgYdyeVj6ZKAq-obPV_64/sendMessage -d text="Kernel compiled successfully in $((DIFF / 60)) minute(s) and $((DIFF % 60)) seconds for SPIRAL" -d chat_id=338913217 -d parse_mode=HTML
	curl -F chat_id=338913217 -F document=@"${HOME}/Anykernel/${ZIPNAME}" https://api.telegram.org/bot1445481247:AAFmjxDbbXAEFjAgYdyeVj6ZKAq-obPV_64/sendDocument
else
	curl -s -X POST https://api.telegram.org/bot1445481247:AAFmjxDbbXAEFjAgYdyeVj6ZKAq-obPV_64/sendMessage -d text="Build Error!!" -d chat_id=338913217
	exit 1;
fi
cd $(pwd)

# Cleanup
