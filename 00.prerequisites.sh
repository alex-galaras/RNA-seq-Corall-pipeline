#Tools you need to perform the pipeline:
#umi_tools
#samtools
#bedtools
#bowtie2
#hisat2
#bedgraphTobigwig


#Genome information you need. In the current example, mm10 is used as a genome template.

###Install umi_tools

if command -v umi_tools &> /dev/null
then
    echo "UMI-tools is already installed."
else
    echo "UMI-tools is not installed. Installing now."

    # Update package list and install umi_tools
    sudo apt-get update
    sudo apt-get install -y umi-tools

    # Verify installation
    if command -v umi_tools &> /dev/null
    then
        echo "UMI-tools has been successfully installed."
    else
        echo "Failed to install UMI-tools."
    fi
fi

### Install samtools

# Check if samtools is installed
if command -v samtools &> /dev/null
then
    echo "Samtools is already installed."
else
    echo "Samtools is not installed. Installing now."

    # Update package list and install samtools
    sudo apt-get update
    sudo apt-get install -y samtools

    # Verify installation
    if command -v samtools &> /dev/null
    then
        echo "Samtools has been successfully installed."
    else
        echo "Failed to install Samtools."
    fi
fi

### Install bedtools

# Check if bedtools is installed
if command -v bedtools &> /dev/null
then
    echo "Bedtools is already installed."
else
    echo "Bedtools is not installed. Installing now."

    # Update package list and install bedtools
    sudo apt-get update
    sudo apt-get install -y bedtools

    # Verify installation
    if command -v bedtools &> /dev/null
    then
        echo "Bedtools has been successfully installed."
    else
        echo "Failed to install Bedtools."
    fi
fi

### Install bowtie2

# Check if bowtie2 is installed
if command -v bowtie2 &> /dev/null
then
    echo "Bowtie2 is already installed."
else
    echo "Bowtie2 is not installed. Installing now."

    # Update package list and install bowtie2
    sudo apt-get update
    sudo apt-get install -y bowtie2

    # Verify installation
    if command -v bowtie2 &> /dev/null
    then
        echo "Bowtie2 has been successfully installed."
    else
        echo "Failed to install Bowtie2."
    fi
fi

### Install hisat2
# Check if hisat2 is installed
if command -v hisat2 &> /dev/null
then
    echo "HISAT2 is already installed."
else
    echo "HISAT2 is not installed. Installing now."

    # Update package list and install hisat2
    sudo apt-get update
    sudo apt-get install -y hisat2

    # Verify installation
    if command -v hisat2 &> /dev/null
    then
        echo "HISAT2 has been successfully installed."
    else
        echo "Failed to install HISAT2."
    fi
fi

### Install bedGraphToBigWig

# Check if bedGraphToBigWig is installed
if command -v bedGraphToBigWig &> /dev/null
then
    echo "bedGraphToBigWig is already installed."
else
    echo "bedGraphToBigWig is not installed. Installing now."
    
    #Install bedGraphToBigWig
    wget http://hgdownload.cse.ucsc.edu/admin/exe/linux.x86_64/bedGraphToBigWig
    # Verify installation
    if command -v bedGraphToBigWig &> /dev/null
    then
        echo "bedGraphToBigWig has been successfully installed."
    else
        echo "Failed to install bedGraphToBigWig."
    fi
fi
