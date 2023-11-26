version 1.0

import "lsgkm.wdl" as lsgkm
import "utils.wdl" as util
import "lsgkm_preproc.wdl" as preproc

workflow lsgkm_from_peak {
    String pipeline_ver = 'v0.1'
    
    input {
        File peakFile
        String peakType = "macs2"
        Int kernelType = 4
        Int L = 11
        Int k = 7
        Int d = 3
        Int ncv = 5
        String genome = "hg38"
        Int extLen = 300
        Int topN = 50000
        Int rseed = 1
        Int nfold = 1
    }

    call preproc.make_positive_set {
        input:
            peakFile = peakFile,
            peakType = peakType,
            genome = genome,
            extLen = extLen,
            topN = topN
    }
    
    call preproc.make_negative_set {
        input:
            posQcBedFile = make_positive_set.posQcBedFile,
            genome = genome,
            rseed = rseed,
            nfold = nfold
    }

    call lsgkm.lsgkm_train { 
        input: 
            posInputFastaFile = make_positive_set.posQcTrFile, 
            negInputFastaFile = make_negative_set.negQcTrFile,
            kernelType = kernelType,
            L = L,
            k = k,
            d = d
    }

    call lsgkm.lsgkm_cv { 
        input: 
            posInputFastaFile = make_positive_set.posQcTrFile, 
            negInputFastaFile = make_negative_set.negQcTrFile,
            kernelType = kernelType,
            L = L,
            k = k,
            d = d,
            ncv = ncv
    }

    call lsgkm.lsgkm_weights { 
        input: 
            modelFile = lsgkm_train.modelFile,
            L = L
    }

    call util.plot_rocpr { 
        input: 
            cvpredFile = lsgkm_cv.cvpredFile
    }

    output {
        File posQcBedFile = make_positive_set.posQcBedFile
        File modelFile = lsgkm_train.modelFile
        File cvpredFile = lsgkm_cv.cvpredFile
        File weightsFile = lsgkm_weights.weightsFile
        File rocprFile= plot_rocpr.rocprFile
    }

    meta {
        author: "Dongwon Lee"
        email: "dongwon.lee@childrens.harvard.edu"
        description: "a simple workflow that train lsgkm"
    }
}
