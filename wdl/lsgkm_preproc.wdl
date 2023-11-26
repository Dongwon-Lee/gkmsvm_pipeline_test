version 1.0

task make_positive_set {
    input {
        File peakFile
        String peakType
        String genome
        Int extLen
        Int topN
    }

    command {
        /software/make_positive_set.sh ${peakFile} ${peakType} ${genome} ${extLen} ${topN} lsgkm_input
    }

    output {
        File posQcBedFile = "lsgkm_input.qc.topn.bed"
        File posQcTrFile = "lsgkm_input.qc.topn.tr.fa"
        File posQcTeFile = "lsgkm_input.qc.topn.te.fa"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 1
        memory: "4 GB"
    }

    parameter_meta {
        peakFile: "narrow peak file from peak calling (MACS2)"
        peakType: "peak caller type: macs2 (default) or hotspot"
        genome: "genome build (default: hg38)"
        extLen: "extension length from the peak summits (default: 300)"
        topN: "number of top peaks for training (default 50,000)"
    }
}

task make_negative_set {
    input {
        File posQcBedFile
        String genome
        Int rseed
        Int nfold
    }

    command {
        /software/make_negative_set.sh ${posQcBedFile} ${genome} ${rseed} ${nfold} lsgkm_input.neg
    }

    output {
        File negQcTrFile = "lsgkm_input.neg.tr.fa"
        File negQcTeFile = "lsgkm_input.neg.te.fa"
    }

    runtime {
        docker: "dongwonlee/gkmsvm_pipeline_test:0.1"
        cpu: 1
        memory: "4 GB"
    }

    parameter_meta {
        posQcBedFile: "positive set file in bed format after QC"
        genome: "genome build"
        rseed: "random seed for generating negative set"
        nfold: "n-fold for negative set"
    }
}
