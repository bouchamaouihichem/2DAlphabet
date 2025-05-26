import ROOT
import os
import numpy as np

ROOT.gROOT.SetBatch(True)
import glob
ROOT.gStyle.SetOptStat(0)  ## Don't display stat boxes

input_dir = "GoF_files/"
output_dir = "Plotting/GoF/" 

# Draw GoF plots 
for channel in ['LepHi', 'LepLo', 'gg0lHi', 'gg0lLo']:
    for mass in ['15', '30', '55']:
        
        # getting expected value
        file_expected =  f"{input_dir}higgsCombine.goodnessOfFit.mA_{mass}.{channel}.GoodnessOfFit.mH125.root"
        f_ex = ROOT.TFile.Open(file_expected)
        if not f_ex or f_ex.IsZombie():
            print(f"❌ Could not open expected file: {file_expected}")
            continue
        tree_ex = f_ex.Get("limit")
        if not tree_ex:
            print(f"❌ 'limit' tree not found in expected file: {file_expected}")
            continue
        tree_ex.GetEntry(0)
        expected_arrow = getattr(tree_ex, "limit")  

        # Getting observed distributions
        file_observed =  f"{input_dir}higgsCombine.goodnessOfFit.mA_{mass}.{channel}.GoodnessOfFit.mH125.123456.root"
        f_obs = ROOT.TFile.Open(file_observed)
        if not f_obs or f_obs.IsZombie():
            print(f"❌ Could not open expected file: {file_observed}")
            continue
        tree_obs = f_obs.Get("limit")
        if not tree_obs:
            print(f"❌ 'limit' tree not found in expected file:  {file_observed}")
            continue
                
        # Create histograms
        h_obs = ROOT.TH1F(f"h_obs_{channel}_{mass}", "Expected and Observed GoF;chi2;Events", 100, 0, 600)
        tree_obs.Draw(f"limit>>h_obs_{channel}_{mass}")
        h_obs.SetLineColor(ROOT.kRed + 1)
        h_obs.SetLineWidth(2)
         
        # Draw
        c = ROOT.TCanvas(f"c_{channel}_{mass}", "", 800, 600)
        h_obs.Draw("hist")        
        arrow = ROOT.TArrow(expected_arrow, 0, expected_arrow, h_obs.GetMaximum() * 0.5, 0.02, "|>")
        arrow.SetLineColor(ROOT.kBlue)
        arrow.SetFillColor(ROOT.kBlue)
        arrow.SetLineWidth(2)
        arrow.Draw("same")

        # Add legend
        legend = ROOT.TLegend(0.55, 0.7, 0.88, 0.85)
        legend.AddEntry(h_obs, "Observed (toys)", "l")
        legend.AddEntry(arrow, "Expected (MC)", "l")
        legend.Draw("same")
       
        # Calculate p-value
        n_total = h_obs.GetEntries()
        bin_index = h_obs.FindBin(expected_arrow)
        n_extreme = sum(h_obs.GetBinContent(i) for i in range(bin_index, h_obs.GetNbinsX() + 1))
        p_value = n_extreme / n_total if n_total > 0 else 1.0

        # Draw p-value on canvas
        label = ROOT.TLatex()
        label.SetNDC()               # Use normalized device coords
        label.SetTextSize(0.035)
        label.SetTextFont(42)
        label.DrawLatex(0.6, 0.62, f"p-value = {p_value:.4f}")
        
        # Save canvas
        c.SaveAs(f"{output_dir}GoodnessOfFit_distribution_{channel}_{mass}.png")


