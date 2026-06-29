import os
import tempfile
from contextlib import contextmanager
from pathlib import Path

import pandas as pd
from sklearn.datasets import make_classification


class AutoMLTestSupport:
    @contextmanager
    def temporary_cwd(self, path):
        original_cwd = os.getcwd()
        os.chdir(path)
        try:
            yield
        finally:
            os.chdir(original_cwd)

    def build_dataset(self):
        X, y = make_classification(
            n_samples=80,
            n_features=6,
            n_informative=4,
            n_redundant=0,
            n_clusters_per_class=1,
            random_state=42,
        )
        df = pd.DataFrame(X, columns=[f"feature_{i}" for i in range(X.shape[1])])
        df["target"] = pd.Series(y).map({0: "negativo", 1: "positivo"})
        return df

    def prepare_csv(self):
        tmpdir = tempfile.TemporaryDirectory()
        df = self.build_dataset()
        csv_path = Path(tmpdir.name) / "dataset.csv"
        df.to_csv(csv_path, index=False)
        return tmpdir, df, csv_path
