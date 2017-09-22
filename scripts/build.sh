#!/bin/bash

# Stop on error
set -e

# Booleans
main_tbu=0
#test_tbu=0
#comp_tbu=0
check_only=0

if test "$1" == "--check-syntax-only"
then
    check_only=1
fi

# Project name
project_name="date_picker_test"
syntax_checker="eslint"

# The main source directories
src_dir="./src/"
tmp_dir="./tmp/"
bin_dir="./bin/"
script_dir="./node_modules/.bin/"

# Main and test files
main_name="${project_name}.js"
#test_name="${project_name}-tests.js"
#component_test_name="${project_name}-component-tests.js"

# Shortcuts
main_base="${src_dir}${main_name}"
main_compiled="${tmp_dir}${main_name}"
main_bundled="${bin_dir}${main_name}"

#test_base="${src_dir}${test_name}"
#test_compiled="${tmp_dir}${test_name}"
#test_bundled="${bin_dir}${test_name}"

#component_test_base="${src_dir}${component_test_name}"
#component_test_compiled="${tmp_dir}${component_test_name}"
#component_test_bundled="${bin_dir}${component_test_name}"

linter="${script_dir}${syntax_checker}"
packer="${script_dir}browserify"

# Custom modules need to be added here
# in order for them to be syntax-checked
declare -a modules=(
    "components/date_picker.js"
)

# Function for checking and compiling modules.
check_file () {
    
    local base_name="$1"
    local base_file="${src_dir}${base_name}"
    local target_file="${tmp_dir}${base_name}"
    
    echo Checking syntax of "${base_name}"...
    "${linter}" "${base_file}"
    echo Compiling "${base_name}"...
    "${script_dir}babel" "${base_file}" --out-file "${target_file}"
    echo
    
}

# Check if any of the modules have been updated
for next_file in "${modules[@]}"
do
    next_full="${src_dir}${next_file}"
    target_full="${tmp_dir}${next_file}"
    
    # If a module has been updated, both the main
    # and test files need to be updated
    if test "${next_full}" -nt "${main_bundled}" || \
            test "${next_full}" -nt "${test_bundled}"
    then
        main_tbu=1
        #test_tbu=1
        #comp_tbu=1
    fi
    
    # If the complied version of the module is older than 
    # the source version, re-compile it.
    if test "${next_full}" -nt "${target_full}"
    then
        check_file "${next_file}"
    fi
done

# Update the polyfill source file, if necessary
#if test "${src_dir}polyfill.js" -nt "${tmp_dir}polyfill.js"
#then
#    echo "Updating polyfill file..."
#    cp "${src_dir}polyfill.js" "${tmp_dir}"
#fi

# Check if the main or test files need to be updated
if test "${main_tbu}" -eq 1 || test "${main_base}" -nt "${main_bundled}"
then
    check_file "${main_name}"
    main_tbu=1
fi

#if test "${test_tbu}" -eq 1 || test "${test_base}" -nt "${test_bundled}"
#then
#    check_file "${test_name}"
#    test_tbu=1
#fi

#if test "${comp_tbu}" -eq 1 || \
#        test "${component_test_base}" -nt "${component_test_bundled}"
#then
#    check_file "${component_test_name}"
#    comp_tbu=1
#fi

# If we're only checking the syntax then go no further
if test "${check_only}" -eq 1
then
    echo Syntax check complete.
    exit 0
fi

# If no updates are detected then exit
#if test "${main_tbu}" -eq 0 && test "${test_tbu}" -eq 0 && \
#        test "${comp_tbu}" -eq 0
if test "${main_tbu}" -eq 0
then
    echo Everything up-to-date.  Exiting.
    exit 0
fi

# Run basic pre-build tests
#echo Running tests...
#"${linter}" "${test_base}"
#node "${test_compiled}" | tap-dot
#echo

# If all OK so far, update the build number
#echo Incrementing build number...
#echo
#build_num="$(<build_number)"
#build_num=$((build_num + 1))
#echo -n "${build_num}" > build_number

# Compile the main source file
if test "${main_tbu}" -eq 1
then
    echo Compiling main source file...
    "${packer}" "${main_compiled}" \
            -o "${main_bundled}"
            #--standalone "${project_name}" \
    echo
fi

# That's far enough for now
exit 0

# Compile the test source file
#if test "${test_tbu}" -eq 1
#then
#    echo Compiling test source file...
#    "${packer}" "${test_compiled}" \
#            --standalone "${project_name}Test" \
#            -o "${test_bundled}"
#    echo
#fi

# Compile the test source file
#if test "${comp_tbu}" -eq 1
#then
#    echo Compiling component test source file...
#    "${packer}" "${component_test_compiled}" \
#            --standalone "${project_name}ComponentTests" \
#            -o "${component_test_bundled}"
#    echo
#fi

# Prompt for a commit message
echo Compilation successful, please enter a commit message.
echo An empty string skips this step.
echo Have you updated the change log?
read -p "> " commit_msg

# If the commit message is not blank,
# update the patch number and commit 
if test -n "${commit_msg}"
then
    version_num="$(cat package.json | \
            grep \"version\": | \
            grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')"
    commit_str="${version_num}.${build_num}: ${commit_msg}"
    npm --no-git-tag-version version patch
    git add -A
    git commit -m "${commit_str}"
else
    # Otherwise just stage any unstaged files
    git add -A
fi

echo Build script complete.
