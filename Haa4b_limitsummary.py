import ROOT
import os
import numpy as np

ROOT.gROOT.SetBatch(True)
import glob
ROOT.gStyle.SetOptStat(0)  ## Don't display stat boxes

# The expected limits for M-15 and M-55 GeV are placeholders until Yihui
# runs the datacards again to obtain the real values 
data_expected_list={
    'leptonic_15':0.0337, 'vbf_15':0.0503, 'ggh_15':0.0327, 'all_15':0.0171,
    'leptonic_30':0.0337, 'vbf_30':0.0503, 'ggh_30':0.0327, 'all_30':0.0171,
    'leptonic_55':0.0337, 'vbf_55':0.0503, 'ggh_55':0.0327, 'all_55':0.0171,
}

input_dir = "/eos/user/h/hboucham/Haa4b/Toys_2D_Alphabet/500_0521/"
output_dir = "Plotting/Limits/"
max_range={'15':0.1, '30':0.2, '55':0.4}
for channel in ['LepHi', 'LepLo', 'gg0lHi', 'gg0lLo']:
    for mass in ['15', '30', '55']:
    #for mass in ['30']:
        # Input files
        file_pattern = f"{input_dir}higgsCombine.testAsymptoticLimits.mA_{mass}.{channel}.toy*.AsymptoticLimits.mH120.root"
        #data_file = "data.root"
        # Get list of toy files
        files = glob.glob(file_pattern)
        # Create histograms
        h_exp = ROOT.TH1F(f"h_exp_{channel}_{mass}", "Expected and Observed Limits;Limit;Events", 100, 0, max_range[mass])
        h_obs = ROOT.TH1F(f"h_obs_{channel}_{mass}", "Expected and Observed Limits;Limit;Events", 100, 0, max_range[mass])
        #h_exp = ROOT.TH1F("h_exp", "Expected and Observed Limits;Limit;Events", 100, 0, 0.1)
        #h_obs = ROOT.TH1F("h_obs", "Expected and Observed Limits;Limit;Events", 100, 0, 0.1)
        for f in files:
            if not os.path.isfile(f):
                continue
            root_file = ROOT.TFile.Open(f)
            if not root_file or root_file.IsZombie():
                continue
            tree = root_file.Get("limit")
            if not tree:
                root_file.Close()
                continue
            for entry in tree:
                if abs(entry.quantileExpected - 0.5) < 1e-4:
                    h_exp.Fill(entry.limit)
                elif entry.quantileExpected == -1:
                    h_obs.Fill(entry.limit)
            root_file.Close()
        
        # Get expected limit from data.root
        #data_expected = None
        #if os.path.isfile(data_file):
        #    f_data = ROOT.TFile.Open(data_file)
        #    if f_data and not f_data.IsZombie():
        #        t_data = f_data.Get("limit")
        #        if t_data:
        #            for entry in t_data:
        #                if abs(entry.quantileExpected - 0.5) < 1e-4:
        #                    data_expected = entry.limit
        #                    break
        #        f_data.Close()

        #data_expected = data_expected_list[f"{channel}_{mass}"]
        
        # Styling
        h_exp.SetLineColor(ROOT.kBlue + 1)
        h_exp.SetLineWidth(2)
        h_obs.SetLineColor(ROOT.kRed + 1)
        h_obs.SetLineWidth(2)
        
        # Draw
        #c = ROOT.TCanvas("c", "", 800, 600)
        c = ROOT.TCanvas(f"c_{channel}_{mass}", "", 800, 600)
        h_exp.Draw("hist")
        h_obs.Draw("hist same")
        
        # Add arrow for expected data
        '''
        if data_expected is not None:
            arrow = ROOT.TArrow(data_expected, 0, data_expected, h_exp.GetMaximum() * 0.5, 0.02, "|>")
            arrow.SetLineColor(ROOT.kOrange)
            arrow.SetFillColor(ROOT.kOrange)
            arrow.SetLineWidth(2)
            arrow.Draw()
        else:
            print("Could not extract expected value from data.root")
        '''
        # Add legend
        legend = ROOT.TLegend(0.55, 0.7, 0.88, 0.85)
        legend.AddEntry(h_exp, "Expected (median, toys)", "l")
        legend.AddEntry(h_obs, "Observed (toys)", "l")
        #if data_expected is not None:
        #    legend.AddEntry(arrow, "Expected (median, data)", "l")
        legend.Draw()
        
        c.SaveAs(f"{output_dir}Limit_distribution_{channel}_{mass}.png")


