import torch.optim as optim
from sklearn.metrics import f1_score

from trainer import train_model
import datahandler
import argparse
import os
import torch
from models.modelseg import SegNet


# Command line arguments 
parser = argparse.ArgumentParser()
parser.add_argument(
    "data_directory", help='Specify the dataset directory path')
parser.add_argument(
    "exp_directory", help='Specify the experiment directory where metrics and model weights shall be stored.')
parser.add_argument("--epochs", default=100, type=int)
parser.add_argument("--batchsize", default=16, type=int)
parser.add_argument("--outputConfig", default=1, type=int)

args = parser.parse_args()

model_suffix = 9

bpath = args.exp_directory
data_dir = args.data_directory
epochs = args.epochs
batchsize = args.batchsize
outputConfig = args.outputConfig


params_model={
        "input_shape": (3,256,256),
        "initial_filters": 32, 
        "num_outputs": 1,
            }

model = SegNet(params_model)

model.train()


# Create the experiment directory if not present
if not os.path.isdir(bpath):
    os.mkdir(bpath)


# Specify the loss function
criterion = torch.nn.MSELoss(reduction='mean')
# Specify the optimizer with a lower learning rate
optimizer = torch.optim.Adam(model.parameters(), lr=1e-4)

# Specify the evalutation metrics
#metrics = {'f1_score': f1_score, 'auroc': roc_auc_score}
metrics = {'f1_score': f1_score}


# Create the dataloader
dataloaders = datahandler.get_dataloader_single_folder(
    data_dir, imageFolder='images', maskFolder='masks', fraction=0.2, batch_size=batchsize)

trained_model = train_model(model, criterion, dataloaders,
                            optimizer, bpath=bpath, metrics=metrics, num_epochs=epochs,suff=model_suffix)


# Save the trained model
torch.save({'model_state_dict':trained_model.state_dict()},os.path.join(bpath,f'weights_mobile_l_{str(model_suffix)}'))
torch.save(model, os.path.join(bpath, f'weights_mobile_l_{str(model_suffix)}_full.pt'))

