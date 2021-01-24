
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

cd /drone/src/

# dtbo files
git clone https://github.com/viciouspup/libufdt-master-utils.git libufdt-master-utils

# clone benzoclang-12.0
if [[ "$@" =~ "benzoclang"* ]]; then
	git clone https://github.com/lineageos/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 --depth=1 -b lineage-17.1 arm64-gcc
	git clone https://github.com/lineageos/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 --depth=1 -b lineage-17.1 arm32-gcc
	git clone https://github.com/BenzoRom/benzoclang-12.0 --depth=1 clang
elif [[ "$@" =~ "proton"* ]]; then
	git clone https://github.com/kdrag0n/proton-clang -b master --depth=1 clang
else
        git clone https://github.com/kdrag0n/proton-clang -b master --depth=1 clang
fi
