#!/bin/bash

# Function to display help information
display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Backup script with encryption"
    echo
    echo "Options:"
    echo "  -d, --directory DIRECTORY  Specify the directory to backup"
    echo "  -c, --compression TYPE     Specify the compression algorithm (none, gzip, bzip, etc)"
    echo "  -o, --output FILENAME      Specify the output file name"
    echo "  -h, --help                 Display this help message"
    exit 1
}

# Function to handle errors and log them to error.log
handle_error() {
    echo "Error: $1" >> error.log
    exit 1
}

# Function to create a backup of the specified directory
backup_directory() {
    local directory=$1
    local compression=$2
    local output_file=$3

    tar cf - "$directory" 2>/dev/null | $compression > "$output_file" || handle_error "Backup failed"
}

# Function to encrypt the backup archive
encrypt_backup() {
    local input_file=$1
    local output_file=$2

    openssl enc -aes-256-cbc -salt -in "$input_file" -out "$output_file" 2>/dev/null || handle_error "Encryption failed"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--directory)
            DIRECTORY=$2
            shift
            ;;
        -c|--compression)
            COMPRESSION=$2
            shift
            ;;
        -o|--output)
            OUTPUT_FILE=$2
            shift
            ;;
        -h|--help)
            display_help
            ;;
        *)
            handle_error "Invalid option: $1"
            ;;
    esac
    shift
done

# Check if all required parameters are provided
if [ -z "$DIRECTORY" ] || [ -z "$COMPRESSION" ] || [ -z "$OUTPUT_FILE" ]; then
    handle_error "Missing required parameters. Use -h or --help for usage information."
fi

# Create backup, compress, and encrypt
backup_directory "$DIRECTORY" "$COMPRESSION" "backup.tar.$COMPRESSION"
encrypt_backup "backup.tar.$COMPRESSION" "$OUTPUT_FILE"

# Clean up temporary files
rm "backup.tar.$COMPRESSION"

echo "Backup completed successfully."