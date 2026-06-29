import unittest

import pandas as pd
from sklearn.linear_model import LinearRegression, LogisticRegression

from data_processing import PowerfulDataProcessor
from model_training import UltraCompleteTrainer
from tests.test_support import AutoMLTestSupport


class TestTraining(unittest.TestCase, AutoMLTestSupport):
    def setUp(self):
        self.tmpdir, self.dataframe, self.csv_path = self.prepare_csv()
        self.addCleanup(self.tmpdir.cleanup)

    def test_training_and_ranking(self):
        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(self.csv_path))

        trainer = UltraCompleteTrainer(problem_type)
        trainer.n_folds = 3
        trainer.get_all_models = lambda: {
            "LogisticRegression": LogisticRegression(max_iter=300, random_state=42)
        }

        results, best_model_name = trainer.train_models(X_processed, y_processed, optimize_top_n=0)

        self.assertIn(best_model_name, results)
        ranking = trainer.get_ranking()
        self.assertFalse(ranking.empty)
        self.assertIn("Modelo", ranking.columns)

    def test_regression_training_and_ranking(self):
        tmpdir, dataframe, csv_path = self.prepare_regression_csv()
        self.addCleanup(tmpdir.cleanup)

        processor = PowerfulDataProcessor(target_column="target", problem_type="auto")
        X_processed, y_processed, problem_type = processor.process(data=pd.read_csv(csv_path))

        trainer = UltraCompleteTrainer(problem_type)
        trainer.n_folds = 3
        trainer.get_all_models = lambda: {
            "LinearRegression": LinearRegression()
        }

        results, best_model_name = trainer.train_models(X_processed, y_processed, optimize_top_n=0)

        self.assertEqual(problem_type, "regression")
        self.assertIn(best_model_name, results)
        ranking = trainer.get_ranking()
        self.assertFalse(ranking.empty)
        self.assertIn("Modelo", ranking.columns)


if __name__ == "__main__":
    unittest.main()
